import Foundation
import PusherPlatform
#if os(iOS) || os(macOS)
import BeamsChatkit
#endif
#if os(iOS)
import UserNotifications
#elseif os(macOS)
import NotificationCenter
#endif

@objc public class ChatManager: NSObject {
    private let chatkitBeamsTokenProviderInstance: Instance
    public let instance: Instance
    public let filesInstance: Instance
    public let cursorsInstance: Instance
    public let presenceInstance: Instance

    public let userID: String
    public let pathFriendlyUserID: String

    let connectionCoordinator: PCConnectionCoordinator
    var currentUser: PCCurrentUser?

    var basicCurrentUser: PCBasicCurrentUser?

    var wasPreviouslyConnected: Bool = false

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

        let sdkInfo = PPSDKInfo(productName: "chatkit", sdkVersion: "1.3.0")
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

        self.chatkitBeamsTokenProviderInstance = ChatManager.createInstance(
            serviceName: "chatkit_beams_token_provider",
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
            serviceVersion: "v2",
            sharedOptions: sharedInstanceOptions
        )

        self.presenceInstance = ChatManager.createInstance(
            serviceName: "chatkit_presence",
            serviceVersion: "v2",
            sharedOptions: sharedInstanceOptions
        )

        self.connectionCoordinator = PCConnectionCoordinator(logger: logger)
        self.userID = userID
        self.pathFriendlyUserID = pathFriendlyVersion(of: userID)

        if let tokenProvider = tokenProvider as? PCTokenProvider {
            tokenProvider.userID = userID
            tokenProvider.logger = logger
        }
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        disconnect() // clear things up first

        self.basicCurrentUser = PCBasicCurrentUser(
            id: userID,
            pathFriendlyID: pathFriendlyUserID,
            instance: instance,
            chatkitBeamsTokenProviderInstance: chatkitBeamsTokenProviderInstance,
            filesInstance: filesInstance,
            cursorsInstance: cursorsInstance,
            presenceInstance: presenceInstance,
            connectionCoordinator: connectionCoordinator,
            delegate: delegate,
            userStore: self.currentUser?.userStore,
            roomStore: self.currentUser?.roomStore,
            cursorStore: self.currentUser?.cursorStore
        )

        // TODO: This could be nicer
        // TODO: Do we need to nil out subscriptions on basicCurrentUser no matter what?
        connectionCoordinator.addConnectionCompletionHandler { [weak self] cUser, error in
            guard error == nil, let cu = cUser else {
                return
            }

            guard let strongSelf = self else {
                return
            }

            cu.userSubscription = strongSelf.basicCurrentUser?.userSubscription
            strongSelf.basicCurrentUser?.userSubscription = nil
            cu.presenceSubscription = strongSelf.basicCurrentUser?.presenceSubscription
            strongSelf.basicCurrentUser?.presenceSubscription = nil
            cu.cursorSubscription = strongSelf.basicCurrentUser?.cursorSubscription
            strongSelf.basicCurrentUser?.cursorSubscription = nil

            strongSelf.wasPreviouslyConnected = true

            // TODO: This is madness
            cu.userSubscription?.currentUser = cu
        }

        basicCurrentUser!.establishUserSubscription(
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
                        chatkitBeamsTokenProviderInstance: strongSelf.chatkitBeamsTokenProviderInstance,
                        filesInstance: strongSelf.filesInstance,
                        cursorsInstance: strongSelf.cursorsInstance,
                        presenceInstance: strongSelf.presenceInstance,
                        userStore: strongSelf.basicCurrentUser!.userStore,
                        roomStore: strongSelf.basicCurrentUser!.roomStore,
                        cursorStore: strongSelf.basicCurrentUser!.cursorStore,
                        connectionCoordinator: strongSelf.connectionCoordinator,
                        delegate: strongSelf.basicCurrentUser!.delegate
                    )
                } catch let err {
                    strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(
                        currentUser: nil,
                        error: err
                    )
                    return
                }

                var oldRooms = Set<PCRoom>()
                var newRooms = Set<PCRoom>()

                // If the currentUser property is already set then the assumption is that there was
                // already a user subscription and so instead of setting the property to a new
                // PCCurrentUser, we update the existing one to have the most up-to-date state
                if let currentUser = strongSelf.currentUser {
                    // We need to take copies of the rooms so that when we make the comparisons
                    // of received rooms to pre-existing rooms we aren't actually just comparing
                    // the same rooms (as PCRoom is a class and we have reference semantics)
                    currentUser.rooms.forEach { oldRooms.insert($0.copy()) }
                    currentUser.updateWithPropertiesOf(receivedCurrentUser)
                } else {
                    strongSelf.currentUser = receivedCurrentUser
                }

                roomsPayload.forEach { roomPayload in
                    do {
                        let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
                        let addedOrMergedRoom = strongSelf.currentUser!.roomStore.addOrMergeSync(room)
                        newRooms.insert(addedOrMergedRoom)
                    } catch let err {
                        strongSelf.instance.logger.log(
                            "Incomplete room payload in initial_state event: \(roomPayload). Error: \(err.localizedDescription)",
                            logLevel: .debug
                        )
                    }
                }

                if strongSelf.wasPreviouslyConnected {
                    let roomsRemovedFrom = oldRooms.subtracting(newRooms)
                    let roomsAddedTo = newRooms.subtracting(oldRooms)

                    roomsRemovedFrom.forEach { room in
                        if let removedRoom = strongSelf.currentUser!.roomStore.removeSync(id: room.id) {
                            delegate.onRemovedFromRoom(removedRoom)
                        }
                    }
                    roomsAddedTo.forEach(delegate.onAddedToRoom)

                    let sharedRooms = newRooms.intersection(oldRooms)

                    sharedRooms.forEach { room in
                        if let oldRoom = oldRooms.first(where: { $0.id == room.id }), !room.deepEqual(to: oldRoom) {
                            delegate.onRoomUpdated(room: room)
                        }
                    }
                }

                strongSelf.informConnectionCoordinatorOfCurrentUserCompletion(currentUser: strongSelf.currentUser, error: nil)
            }
        )

        basicCurrentUser!.establishPresenceSubscription()
        basicCurrentUser!.establishCursorSubscription(
            initialStateHandler: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }

                if strongSelf.wasPreviouslyConnected, let currentUser = strongSelf.currentUser {
                    switch result {
                    case .error(_):
                        return
                    case .success(let existing, let new):
                        reconcileCursors(
                            new: new,
                            old: existing,
                            onNewReadCursorHook: { [weak currentUser] cursor in
                                currentUser?.delegate.onNewReadCursor(cursor)
                                // We only do this here because we currently still deliver cursor updates
                                // about the current user over the room level onNewReadCursor hook. Once
                                // we no longer support that then this can be removed.
                                if let room = currentUser?.rooms.first(where: { $0.id == cursor.room.id }) {
                                    room.subscription?.delegate?.onNewReadCursor(cursor)
                                }
                            }
                        )
                    }
                }
            }
        )

        // This being here at the end seems necessary but bad - we want to
        // call the developer-provided completionHandler last because we
        // need to have our completionHandler(s) called first to make sure
        // everything is in the correct state
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
        currentUser?.userPresenceSubscriptions.forEach { $0.value.end() }
        currentUser?.userPresenceSubscriptions.removeAll()
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

func reconcileCursors(
    new: [PCCursor],
    old: [PCCursor],
    onNewReadCursorHook: ((PCCursor) -> Void)?
) {
    let oldSet = Set(old)
    let newSet = Set(new)

    let newCursors = newSet.subtracting(oldSet)

    newCursors.forEach { c in onNewReadCursorHook?(c) }

    let commonCursors = newSet.intersection(oldSet)

    commonCursors.forEach { cursor in
        let oldCursor = oldSet.first(where: {
            $0.type == cursor.type &&
            $0.room == cursor.room &&
            $0.user == cursor.user
        })

        if let oldCursor = oldCursor,
           cursor.equalBarPositionTo(oldCursor),
           cursor.position != oldCursor.position
        {
            onNewReadCursorHook?(cursor)
        }
    }
}

func pathFriendlyVersion(of component: String) -> String {
    let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    // TODO: When can percent encoding fail?
    return component.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? component
}


#if os(iOS) || os(macOS)
// MARK: Beams
private let pushNotifications: PushNotifications = PushNotifications.shared

extension ChatManager {
    /**
     Register device token with PushNotifications service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     */
    public static func registerDeviceToken(_ deviceToken: Data) {
        pushNotifications.registerDeviceToken(deviceToken)
    }
    /**
     Register to receive remote notifications via Apple Push Notification service.

     Convenience method is using `.alert`, `.sound`, and `.badge` as default authorization options.

     - SeeAlso:  `registerForRemoteNotifications(options:)`
     */
    public static func registerForRemoteNotifications() {
        pushNotifications.registerForRemoteNotifications()
    }
    #if os(iOS)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: The authorization options your app is requesting. You may combine the available constants to request authorization for multiple items. Request only the authorization options that you plan to use. For a list of possible values, see [UNAuthorizationOptions](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions).
     */
    public static func registerForRemoteNotifications(options: UNAuthorizationOptions) {
        pushNotifications.registerForRemoteNotifications(options: options)
    }
    #elseif os(macOS)
    /**
     Register to receive remote notifications via Apple Push Notification service.

     - Parameter options: A bit mask specifying the types of notifications the app accepts. See [NSApplication.RemoteNotificationType](https://developer.apple.com/documentation/appkit/nsapplication.remotenotificationtype) for valid bit-mask values.
     */
    public static func registerForRemoteNotifications(options: NSApplication.RemoteNotificationType) {
        pushNotifications.registerForRemoteNotifications(options: options)
    }
    #endif
    /**
     Disable push notifications service.
     */
    public static func disablePushNotifications() {
        pushNotifications.clearAllState { (error) in
            guard error == nil else {
                let logger = PCDefaultLogger()
                return logger.log("Error occured while clearing the state: \(error!)", logLevel: .error)
            }
        }
    }
}
#endif
