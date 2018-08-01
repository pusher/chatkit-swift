import Foundation
import PusherPlatform

@objc public class ChatManager: NSObject {
    public let instance: Instance
    public let filesInstance: Instance
    public let cursorsInstance: Instance
    public let presenceInstance: Instance

    public let userId: String
    public let pathFriendlyUserId: String

    let connectionCoordinator: PCConnectionCoordinator
    var currentUser: PCCurrentUser?

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
        userId: String,
        logger: PCLogger = PCDefaultLogger(),
        baseClient: PCBaseClient? = nil
    ) {
        let splitInstance = instanceLocator.split(separator: ":")
        let cluster = splitInstance[1]

        self.logger = logger

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "0.10.2")
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
            tokenProvider.userId = userId
            tokenProvider.logger = logger
        }

        self.userId = userId
        self.pathFriendlyUserId = pathFriendlyUserID(userId)
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        disconnect() // clear things up first

        let basicCurrentUser = PCBasicCurrentUser(
            id: userId,
            pathFriendlyId: pathFriendlyUserId,
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

            cu.userSubscription = basicCurrentUser.userSubscription
            basicCurrentUser.userSubscription = nil
            cu.presenceSubscription = basicCurrentUser.presenceSubscription
            basicCurrentUser.presenceSubscription = nil
            cu.cursorSubscription = basicCurrentUser.cursorSubscription
            basicCurrentUser.cursorSubscription = nil

            // TODO: This is madness
            cu.userSubscription?.currentUser = cu
        }

        basicCurrentUser.establishUserSubscription(
            initialStateHandler: { [unowned self] currentUserPayloadTuple in
                let (roomsPayload, currentUserPayload) = currentUserPayloadTuple

                let receivedCurrentUser: PCCurrentUser

                do {
                    receivedCurrentUser = try PCPayloadDeserializer.createCurrentUserFromPayload(
                        currentUserPayload,
                        id: self.userId,
                        pathFriendlyId: self.pathFriendlyUserId,
                        instance: self.instance,
                        filesInstance: self.filesInstance,
                        cursorsInstance: self.cursorsInstance,
                        presenceInstance: self.presenceInstance,
                        userStore: basicCurrentUser.userStore,
                        roomStore: basicCurrentUser.roomStore,
                        cursorStore: basicCurrentUser.cursorStore,
                        connectionCoordinator: self.connectionCoordinator,
                        delegate: basicCurrentUser.delegate
                    )
                } catch let err {
                    self.informConnectionCoordinatorOfCurrentUserCompletion(
                        currentUser: nil,
                        error: err
                    )
                    return
                }

                // If the currentUser property is already set then the assumption is that there was
                // already a user subscription and so instead of setting the property to a new
                // PCCurrentUser, we update the existing one to have the most up-to-date state
                if let currentUser = self.currentUser {
                    currentUser.updateWithPropertiesOf(receivedCurrentUser)
                } else {
                    self.currentUser = receivedCurrentUser
                }

                guard roomsPayload.count > 0 else {
                    self.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: self.currentUser, error: nil)
                    return
                }

                let roomsAddedToRoomStoreProgressCounter = PCProgressCounter(
                    totalCount: roomsPayload.count,
                    labelSuffix: "roomstore-room-append"
                )

                var combinedRoomUserIds = Set<String>()

                roomsPayload.forEach { roomPayload in
                    do {
                        let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

                        combinedRoomUserIds.formUnion(room.userIds)

                        self.currentUser!.roomStore.addOrMergeSync(room)
                        if roomsAddedToRoomStoreProgressCounter.incrementSuccessAndCheckIfFinished() {
                            self.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: self.currentUser, error: nil)
                        }
                    } catch let err {
                        self.instance.logger.log(
                            "Incomplete room payload in initial_state event: \(roomPayload). Error: \(err.localizedDescription)",
                            logLevel: .debug
                        )
                        if roomsAddedToRoomStoreProgressCounter.incrementFailedAndCheckIfFinished() {
                            self.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: self.currentUser, error: nil)
                        }
                    }
                }
            }
        )

        basicCurrentUser.establishPresenceSubscription()
        basicCurrentUser.establishCursorSubscription()

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
        currentUser?.userPresenceSubscripitons.forEach { uPSub in
            uPSub.value.end()
            let _ = currentUser?.userPresenceSubscripitons.removeValue(forKey: uPSub.key)
        }
        connectionCoordinator.reset()
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

func pathFriendlyUserID(_ userID: String) -> String {
    let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    // TODO: When can percent encoding fail?
    return userID.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? userID
}
