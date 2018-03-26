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

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "0.6.4")

        let sharedInstanceOptions = PCSharedInstanceOptions(
            locator: instanceLocator,
            sdkInfo: sdkInfo,
            tokenProvider: tokenProvider,
            baseClient: sharedBaseClient,
            logger: logger
        )

        self.instance = ChatManager.createInstance(
            serviceName: "chatkit",
            serviceVersion: "v1",
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

    public func addConnectCompletionHandler(completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
        connectionCoordinator.addConnectionCompletionHandler(completionHandler)
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        addConnectCompletionHandler(completionHandler: completionHandler)

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
        connectionCoordinator.connectionEventHandlers.append(
            PCConnectionEventHandler(
                handler: { events in
                    for event in events {
                        switch event.result {
                        case .userSubscriptionInit(let currentUser, _):
                            currentUser?.userSubscription = basicCurrentUser.userSubscription
                            currentUser?.presenceSubscription = basicCurrentUser.presenceSubscription
                            currentUser?.cursorSubscription = basicCurrentUser.cursorSubscription
                        default:
                            break
                        }
                    }
                },
                dependencies: [
                    PCUserSubscriptionInitEvent,
                    PCPresenceSubscriptionInitEvent,
                    PCCursorSubscriptionInitEvent
                ]
            )
        )

        basicCurrentUser.establishUserSubscription(
            delegate: delegate,
            initialStateHandler: { currentUserPayloadTuple in
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
                    // There are no users to fetch information about so we are safe to inform
                    // the connection coordinator of a success immediately
                    self.informConnectionCoordinatorOfInitialUsersFetchCompletion(users: [], error: nil)
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

                        self.currentUser!.roomStore.addOrMerge(room) { _ in
                            if roomsAddedToRoomStoreProgressCounter.incrementSuccessAndCheckIfFinished() {
                                self.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: self.currentUser, error: nil)
                                self.fetchInitialUserInformationForUserIds(
                                    combinedRoomUserIds,
                                    userStore: self.currentUser!.userStore,
                                    roomStore: self.currentUser!.roomStore
                                )
                            }
                        }
                    } catch let err {
                        self.instance.logger.log(
                            "Incomplete room payload in initial_state event: \(roomPayload). Error: \(err.localizedDescription)",
                            logLevel: .debug
                        )
                        if roomsAddedToRoomStoreProgressCounter.incrementFailedAndCheckIfFinished() {
                            self.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: self.currentUser, error: nil)
                            self.fetchInitialUserInformationForUserIds(
                                combinedRoomUserIds,
                               userStore: self.currentUser!.userStore,
                               roomStore: self.currentUser!.roomStore
                            )
                        }
                    }
                }
            }
        )

        basicCurrentUser.establishPresenceSubscription(delegate: delegate)
        basicCurrentUser.establishCursorSubscription()
    }

    // TODO: Maybe we need some sort of ChatManagerConnectionState?
    public func disconnect() {
        currentUser?.userSubscription?.end()
        currentUser?.presenceSubscription?.end()
        currentUser?.cursorSubscription?.end()
        currentUser?.rooms.forEach { room in
            room.subscription?.end()
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

    fileprivate func fetchInitialUserInformationForUserIds(
        _ userIds: Set<String>,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore
    ) {
        userStore.initialFetchOfUsersWithIds(userIds) { users, err in
            guard err == nil else {
                self.instance.logger.log(
                    "Unable to fetch user information after successful connection: \(err!.localizedDescription)",
                    logLevel: .debug
                )
                self.informConnectionCoordinatorOfInitialUsersFetchCompletion(users: nil, error: err!)
                return
            }

            let combinedRoomUsersProgressCounter = PCProgressCounter(totalCount: roomStore.rooms.count, labelSuffix: "room-users-combined")

            // TODO: This could be a lot more efficient
            roomStore.rooms.forEach { room in
                let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIds.count, labelSuffix: "room-users")

                room.userIds.forEach { userId in
                    userStore.user(id: userId) { [weak self] user, err in
                        guard let strongSelf = self else {
                            print("self is nil when user store returns user after initial fetch of users")
                            return
                        }

                        guard let user = user, err == nil else {
                            strongSelf.instance.logger.log(
                                "Unable to add user with id \(userId) to room \(room.name): \(err!.localizedDescription)",
                                logLevel: .debug
                            )
                            if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                                room.subscription?.delegate.usersUpdated()
                                strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)

                                if combinedRoomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                                    strongSelf.informConnectionCoordinatorOfInitialUsersFetchCompletion(users: nil, error: err!)
                                }
                            }
                            return
                        }

                        room.userStore.addOrMerge(user)

                        if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                            room.subscription?.delegate.usersUpdated()
                            strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)

                            if combinedRoomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                                strongSelf.informConnectionCoordinatorOfInitialUsersFetchCompletion(users: users, error: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    fileprivate func informConnectionCoordinatorOfCurrentUserCompletion(currentUser: PCCurrentUser?, error: Error?) {
        connectionCoordinator.connectionEventCompleted(PCConnectionEvent(currentUser: currentUser, error: error))
    }

    fileprivate func informConnectionCoordinatorOfInitialUsersFetchCompletion(users: [PCUser]?, error: Error?) {
        connectionCoordinator.connectionEventCompleted(PCConnectionEvent(users: users, error: error))
    }
}
