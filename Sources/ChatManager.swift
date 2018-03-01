import Foundation
import PusherPlatform

@objc public class ChatManager: NSObject {
    public let instance: Instance
    public let filesInstance: Instance
    public let cursorsInstance: Instance
    public let presenceInstance: Instance

    public let userId: String
    public let pathFriendlyUserId: String

    public internal(set) var userSubscription: PCUserSubscription?

    public var currentUser: PCCurrentUser? {
        return self.userSubscription?.currentUser
    }

    let userStore: PCGlobalUserStore

    let connectionCoordinator: PCConnectionCoordinator

    // TODO: Do we need this here? Should it instead just live on the PCCurrentUser?
    public var users: Set<PCUser> {
        return self.userStore.users
    }

    public init(
        instanceLocator: String,
        tokenProvider: PPTokenProvider,
        userId: String,
        logger: PPLogger = PPDefaultLogger(),
        baseClient: PPBaseClient? = nil
    ) {
        let splitInstance = instanceLocator.split(separator: ":")
        let cluster = splitInstance[1]
        let sharedBaseClient = baseClient ?? PPBaseClient(host: "\(cluster).pusherplatform.io")
        sharedBaseClient.logger = logger

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "0.6.4")

        self.instance = Instance(
            locator: instanceLocator,
            serviceName: "chatkit",
            serviceVersion: "v1",
            sdkInfo: sdkInfo,
            tokenProvider: tokenProvider,
            client: baseClient,
            logger: logger
        )

        self.filesInstance = Instance(
            locator: instanceLocator,
            serviceName: "chatkit_files",
            serviceVersion: "v1",
            sdkInfo: sdkInfo,
            tokenProvider: tokenProvider,
            client: baseClient,
            logger: logger
        )

        self.cursorsInstance = Instance(
            locator: instanceLocator,
            serviceName: "chatkit_cursors",
            serviceVersion: "v1",
            sdkInfo: sdkInfo,
            tokenProvider: tokenProvider,
            client: baseClient,
            logger: logger
        )

        self.presenceInstance = Instance(
            locator: instanceLocator,
            serviceName: "chatkit_presence",
            serviceVersion: "v1",
            sdkInfo: sdkInfo,
            tokenProvider: tokenProvider,
            client: baseClient,
            logger: logger
        )

        self.connectionCoordinator = PCConnectionCoordinator(logger: logger)

        if let tokenProvider = tokenProvider as? PCTokenProvider {
            tokenProvider.userId = userId
            tokenProvider.logger = logger
        }
        self.userStore = PCGlobalUserStore(instance: self.instance)
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
        connectionCoordinator.connectionEventHandlers.append(
            PCConnectionEventHandler(
                handler: { [weak self] events in
                    guard let strongSelf = self else {
                        print("self is nil when calling connection completion handler")
                        return
                    }

                    guard events.count == 2 else {
                        strongSelf.instance.logger.log(
                            "Expected 2 events to be provided to connection event handler, but received \(events.count)",
                            logLevel: .error
                        )
                        return
                    }

                    var currentUser: PCCurrentUser!
                    var roomIdsToCursors: [Int: PCBasicCursor]!

                    for event in events {
                        switch event.result {
                        case .userSubscriptionInit(let curUser, let error):
                            guard curUser != nil else {
                                strongSelf.instance.logger.log(
                                    "Error when getting current user object from connection event handler when about to set cursors: \(error!.localizedDescription)",
                                    logLevel: .error
                                )
                                return
                            }
                            currentUser = curUser!
                        case .initialCursorsFetch(let idsToCursors, let error):
                            guard idsToCursors != nil else {
                                strongSelf.instance.logger.log(
                                    "Error when getting room ids to basic cursors object from connection event handler when about to set cursors: \(error!.localizedDescription)",
                                    logLevel: .error
                                )
                                return
                            }
                            roomIdsToCursors = idsToCursors!
                        default:
                            break
                        }
                    }

                    roomIdsToCursors.forEach { roomIdToCursor in
                        guard let room = currentUser.rooms.first(where: { $0.id == roomIdToCursor.key }) else {
                            strongSelf.instance.logger.log(
                                "Received an initial cursor for room \(roomIdToCursor.key) but the current user object didn't know about the room",
                                logLevel: .debug
                            )
                            return
                        }
                        strongSelf.instance.logger.log(
                            "Setting current user's cursor: (\(roomIdToCursor.value), for room \(room.name)",
                            logLevel: .verbose
                        )
                        room.currentUserCursor = .set(roomIdToCursor.value)
                    }

                    let roomIdsFromCursorsData = roomIdsToCursors.map { $0.key }
                    currentUser.rooms.filter { !roomIdsFromCursorsData.contains($0.id) }.forEach {
                        $0.currentUserCursor = .unset
                    }

                    // TODO: Does this stuff need to be done synchronously?
                    currentUser.pendingRoomSubscriptions.forEach { roomSubInfo in
                        strongSelf.instance.logger.log(
                            "Processing pending room subscription for room: \(roomSubInfo.room.debugDescription)",
                            logLevel: .verbose
                        )
                        if let messageLimit = roomSubInfo.messageLimit {
                            currentUser.subscribeToRoom(
                                room: roomSubInfo.room,
                                roomDelegate: roomSubInfo.roomDelegate,
                                messageLimit: messageLimit
                            )
                        } else {
                            currentUser.subscribeToRoom(room: roomSubInfo.room, roomDelegate: roomSubInfo.roomDelegate)
                        }
                    }
                    currentUser.pendingRoomSubscriptions = []
                },
                dependencies: [PCUserSubscriptionInitEvent, PCInitialCursorsFetchCompletedEvent]
            )
        )

        let path = "/users"
        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            instance: self.instance,
            requestOptions: subscribeRequest
        )

        self.userSubscription = PCUserSubscription(
            instance: self.instance,
            filesInstance: self.filesInstance,
            cursorsInstance: self.cursorsInstance,
            presenceInstance: self.presenceInstance,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            delegate: delegate,
            userId: userId,
            pathFriendlyUserId: pathFriendlyUserId,
            connectionCoordinator: connectionCoordinator
        )

        // TODO: Decide what to do with onEnd
        self.instance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: self.userSubscription!.handleEvent,
            onEnd: { _, _, _ in },
            onError: { error in
                self.connectionCoordinator.connectionEventCompleted(PCConnectionEvent(currentUser: nil, error: error))
            }
        )

        let getCursorsPath = "/cursors/\(PCCursorType.read.rawValue)/users/\(self.pathFriendlyUserId)"
        let cursorsRequestOptions = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: getCursorsPath)

        self.cursorsInstance.requestWithRetry(
            using: cursorsRequestOptions,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    self.connectionCoordinator.connectionEventCompleted(
                        PCConnectionEvent(roomIdsToBasicCursors: nil, error: PCError.failedToDeserializeJSON(data))
                    )
                    return
                }

                guard let cursorsPayload = jsonObject as? [[String: Any]] else {
                    self.connectionCoordinator.connectionEventCompleted(
                        PCConnectionEvent(roomIdsToBasicCursors: nil, error: PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    )
                    return
                }

                var roomIdsToBasicCursors: [Int: PCBasicCursor] = [:]
                cursorsPayload.forEach { cursorPayload in
                    do {
                        let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(cursorPayload)
                        roomIdsToBasicCursors[basicCursor.roomId] = basicCursor
                    } catch let err {
                        self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                    }
                }

                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(roomIdsToBasicCursors: roomIdsToBasicCursors, error: nil)
                )
            },
            onError: { err in
                self.instance.logger.log("Error fetching initial cursors for user: \(err.localizedDescription)", logLevel: .debug)
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(roomIdsToBasicCursors: nil, error: err)
                )
            }
        )
    }

    // TODO: Maybe we need some sort of ChatManagerConnectionState?

    public func disconnect() {
        // End all subscriptions
        userSubscription?.resumableSubscription.end()
        currentUser?.presenceSubscription?.end()
        currentUser?.rooms.forEach { room in
            room.subscription?.resumableSubscription.end()
        }
        connectionCoordinator.reset()
    }
}
