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

    public init(
        instanceLocator: String,
        tokenProvider: PPTokenProvider,
        userId: String,
        logger: PCLogger = PCDefaultLogger(),
        baseClient: PCBaseClient? = nil
    ) {
        let splitInstance = instanceLocator.split(separator: ":")
        let cluster = splitInstance[1]
        let sharedBaseClient = baseClient ?? PCBaseClient(host: "\(cluster).pusherplatform.io")
        sharedBaseClient.logger = logger

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "0.9.0")

        let sharedInstanceOptions = PCSharedInstanceOptions(
            locator: instanceLocator,
            sdkInfo: sdkInfo,
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
            serviceVersion: "v1",
            sharedOptions: sharedInstanceOptions
        )

        self.connectionCoordinator = PCConnectionCoordinator(logger: logger)

        if let tokenProvider = tokenProvider as? PCTokenProvider {
            tokenProvider.userId = userId
            tokenProvider.logger = logger
        }

        self.userId = userId

        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        // TODO: When can percent encoding fail?
        self.pathFriendlyUserId = userId.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? userId
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        let basicCurrentUser = PCBasicCurrentUser(
            id: userId,
            pathFriendlyId: pathFriendlyUserId,
            instance: instance,
            filesInstance: filesInstance,
            cursorsInstance: cursorsInstance,
            presenceInstance: presenceInstance,
            connectionCoordinator: connectionCoordinator
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
            delegate: delegate,
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
                        connectionCoordinator: self.connectionCoordinator
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

        basicCurrentUser.establishPresenceSubscription(delegate: delegate)
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
            sdkInfo: options.sdkInfo,
            tokenProvider: options.tokenProvider,
            client: options.baseClient,
            logger: options.logger
        )
    }

    fileprivate func informConnectionCoordinatorOfCurrentUserCompletion(currentUser: PCCurrentUser?, error: Error?) {
        connectionCoordinator.connectionEventCompleted(PCConnectionEvent(currentUser: currentUser, error: error))
    }
}
