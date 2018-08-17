import Foundation
import PusherPlatform

@objc public class ChatManager: NSObject {
    public let instance: Instance
    public let filesInstance: Instance
    public let cursorsInstance: Instance
    public let presenceInstance: Instance

    public let userID: String
    public let pathFriendlyUserID: String

    let connectionCoordinator: PCConnectionCoordinator
    var currentUser: PCCurrentUser?

    var basicCurrentUser: PCBasicCurrentUser?

    var logger: PCLogger {
        didSet {
            connectionCoordinator.logger = logger
            instance.logger = logger
            filesInstance.logger = logger
            cursorsInstance.logger = logger
            presenceInstance.logger = logger
        }
    }

    public init(
        instanceLocator: String,
        tokenProvider: PPTokenProvider,
        userID: String,
        logger: PCLogger = PCDefaultLogger(),
        baseClient: PCBaseClient? = nil
    ) {
        let splitInstance = instanceLocator.split(separator: ":")
        let cluster = splitInstance[1]

        self.logger = logger

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "0.10.3")
        let sharedBaseClient = baseClient ?? PCBaseClient(host: "\(cluster).pusherplatform.io", sdkInfo: sdkInfo)
        sharedBaseClient.logger = logger

        let sharedInstanceOptions = PCSharedInstanceOptions(
            locator: instanceLocator,
            tokenProvider: tokenProvider,
            baseClient: sharedBaseClient,
            logger: logger
        )

        self.instance = ChatManager.createInstance(
            serviceName: "chatkit",
            serviceVersion: "v2",
            sharedOptions: sharedInstanceOptions
        )

        self.filesInstance = ChatManager.createInstance(
            serviceName: "chatkit_files",
            serviceVersion: "v1",
            sharedOptions: sharedInstanceOptions
        )

        self.cursorsInstance = ChatManager.createInstance(
            serviceName: "chatkit_cursors",
            serviceVersion: "v1",
            sharedOptions: sharedInstanceOptions
        )

        self.presenceInstance = ChatManager.createInstance(
            serviceName: "chatkit_presence",
            serviceVersion: "v2",
            sharedOptions: sharedInstanceOptions
        )

        self.connectionCoordinator = PCConnectionCoordinator(logger: logger)

        if let tokenProvider = tokenProvider as? PCTokenProvider {
            tokenProvider.userID = userID
            tokenProvider.logger = logger
        }

        self.userID = userID
        self.pathFriendlyUserID = pathFriendlyVersion(of: userID)
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        disconnect() // clear things up first

        let basicCurrentUser = PCBasicCurrentUser(
            id: userID,
            pathFriendlyID: pathFriendlyUserID,
            instance: instance,
            filesInstance: filesInstance,
            cursorsInstance: cursorsInstance,
            presenceInstance: presenceInstance,
            connectionCoordinator: connectionCoordinator,
            delegate: delegate
        )

        // TODO: This could be nicer
        // TODO: We don't need to wait for initial user fetch here, but we are
        // TODO: Do we need to nil out subscriptions on basicCurrentUser no matter what?
        connectionCoordinator.addConnectionCompletionHandler { cUser, error in
            guard error == nil, let cu = cUser else {
                return
            }

            cu.userSubscription = self.basicCurrentUser?.userSubscription
            self.basicCurrentUser?.userSubscription = nil
            cu.presenceSubscription = self.basicCurrentUser?.presenceSubscription
            self.basicCurrentUser?.presenceSubscription = nil
            cu.cursorSubscription = self.basicCurrentUser?.cursorSubscription
            self.basicCurrentUser?.cursorSubscription = nil

            // TODO: This is madness
            cu.userSubscription?.currentUser = cu
        }

        basicCurrentUser.establishUserSubscription(
            initialStateHandler: { [weak self] currentUserPayloadTuple in
                guard let strongSelf = self else {
                    print("self is nil in initialStateHandler for userSubscription")
                    return
                }

                let (roomsPayload, currentUserPayload) = currentUserPayloadTuple

                let receivedCurrentUser: PCCurrentUser

                do {
                    receivedCurrentUser = try PCPayloadDeserializer.createCurrentUserFromPayload(
                        currentUserPayload,
                        id: strongSelf.userID,
                        pathFriendlyID: strongSelf.pathFriendlyUserID,
                        instance: strongSelf.instance,
                        filesInstance: strongSelf.filesInstance,
                        cursorsInstance: strongSelf.cursorsInstance,
                        presenceInstance: strongSelf.presenceInstance,
                        userStore: basicCurrentUser.userStore,
                        roomStore: basicCurrentUser.roomStore,
                        cursorStore: basicCurrentUser.cursorStore,
                        connectionCoordinator: strongSelf.connectionCoordinator,
                        delegate: basicCurrentUser.delegate
                    )
                } catch let err {
                    strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(
                        currentUser: nil,
                        error: err
                    )
                    return
                }

                // If the currentUser property is already set then the assumption is that there was
                // already a user subscription and so instead of setting the property to a new
                // PCCurrentUser, we update the existing one to have the most up-to-date state
                if let currentUser = strongSelf.currentUser {
                    currentUser.updateWithPropertiesOf(receivedCurrentUser)
                } else {
                    strongSelf.currentUser = receivedCurrentUser
                }

                guard roomsPayload.count > 0 else {
                    strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: strongSelf.currentUser, error: nil)
                    return
                }

                let roomsAddedToRoomStoreProgressCounter = PCProgressCounter(
                    totalCount: roomsPayload.count,
                    labelSuffix: "roomstore-room-append"
                )

                var combinedRoomUserIDs = Set<String>()

                roomsPayload.forEach { roomPayload in
                    do {
                        let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

                        combinedRoomUserIDs.formUnion(room.userIDs)

                        strongSelf.currentUser!.roomStore.addOrMergeSync(room)
                        if roomsAddedToRoomStoreProgressCounter.incrementSuccessAndCheckIfFinished() {
                            strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: strongSelf.currentUser, error: nil)
                        }
                    } catch let err {
                        strongSelf.instance.logger.log(
                            "Incomplete room payload in initial_state event: \(roomPayload). Error: \(err.localizedDescription)",
                            logLevel: .debug
                        )
                        if roomsAddedToRoomStoreProgressCounter.incrementFailedAndCheckIfFinished() {
                            strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: strongSelf.currentUser, error: nil)
                        }
                    }
                }
            }
        )

        basicCurrentUser!.establishPresenceSubscription()
        basicCurrentUser!.establishCursorSubscription()

        // TODO: This being here at the end seems necessary but bad
        connectionCoordinator.addConnectionCompletionHandler(completionHandler)
    }

    // TODO: Maybe we need some sort of ChatManagerConnectionState?
    public func disconnect() {
        currentUser?.userSubscription?.end()
        currentUser?.userSubscription = nil
        currentUser?.presenceSubscription?.end()
        currentUser?.presenceSubscription = nil
        currentUser?.cursorSubscription?.end()
        currentUser?.cursorSubscription = nil
        currentUser?.rooms.forEach { room in
            room.subscription?.end()
            room.subscription = nil
        }
        currentUser?.userPresenceSubscripitons.forEach { $0.value.end() }
        currentUser?.userPresenceSubscripitons.removeAll()
        connectionCoordinator.reset()
        basicCurrentUser = nil
    }

    fileprivate static func createInstance(
        serviceName: String,
        serviceVersion: String,
        sharedOptions options: PCSharedInstanceOptions
    ) -> Instance {
        return Instance(
            locator: options.locator,
            serviceName: serviceName,
            serviceVersion: serviceVersion,
            client: options.baseClient,
            tokenProvider: options.tokenProvider,
            logger: options.logger
        )
    }

    fileprivate func informConnectionCoordinatorOfCurrentUserCompletion(currentUser: PCCurrentUser?, error: Error?) {
        connectionCoordinator.connectionEventCompleted(PCConnectionEvent(currentUser: currentUser, error: error))
    }
}

func pathFriendlyVersion(of component: String) -> String {
    let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    // TODO: When can percent encoding fail?
    return component.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? component
}
