import Foundation
import PusherPlatform

public final class PCBasicCurrentUser {
    public let id: String
    public let pathFriendlyId: String

    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let cursorStore: PCCursorStore

    public internal(set) var userSubscription: PCUserSubscription?
    public internal(set) var presenceSubscription: PCPresenceSubscription?
    public internal(set) var cursorSubscription: PCCursorSubscription?

    let instance: Instance
    let filesInstance: Instance
    let cursorsInstance: Instance
    let presenceInstance: Instance

    let connectionCoordinator: PCConnectionCoordinator

    public init(
        id: String,
        pathFriendlyId: String,
        instance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
        presenceInstance: Instance,
        connectionCoordinator: PCConnectionCoordinator
    ) {
        self.id = id
        self.pathFriendlyId = pathFriendlyId
        self.instance = instance
        self.filesInstance = filesInstance
        self.cursorsInstance = cursorsInstance
        self.presenceInstance = presenceInstance
        self.connectionCoordinator = connectionCoordinator

        let rooms = PCSynchronizedArray<PCRoom>()
        self.userStore = PCGlobalUserStore(instance: instance)
        self.roomStore = PCRoomStore(rooms: rooms, instance: instance)
        self.cursorStore = PCCursorStore(
            instance: instance,
            roomStore: roomStore,
            userStore: userStore
        )
    }

    func establishUserSubscription(
        delegate: PCChatManagerDelegate,
        initialStateHandler: @escaping ((roomsPayload: [[String: Any]], currentUserPayload: [String: Any])) -> Void
    ) {
        let path = "/users"
        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            instance: self.instance,
            requestOptions: subscribeRequest
        )

        let userSub = PCUserSubscription(
            instance: self.instance,
            filesInstance: self.filesInstance,
            cursorsInstance: self.cursorsInstance,
            presenceInstance: self.presenceInstance,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            delegate: delegate,
            userId: id,
            pathFriendlyUserId: pathFriendlyId,
            connectionCoordinator: connectionCoordinator,
            initialStateHandler: initialStateHandler
        )

        self.userSubscription = userSub

        // TODO: Decide what to do with onEnd
        self.instance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: { [unowned userSub] eventID, headers, data in
                userSub.handleEvent(eventId: eventID, headers: headers, data: data)
            },
            onEnd: { _, _, _ in },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(currentUser: nil, error: error)
                )
            }
        )
    }

    func establishPresenceSubscription(delegate: PCChatManagerDelegate) {
        // If a presenceSubscription already exists then we want to create a new one
        // to ensure that the most up-to-date state is received, so we first close the
        // existing subscription, if it was still open
        if let presSub = self.presenceSubscription {
            presSub.end()
            self.presenceSubscription = nil
        }

        let path = "/users/\(self.pathFriendlyId)/presence"
        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            instance: self.presenceInstance,
            requestOptions: subscribeRequest
        )

        let presenceSub = PCPresenceSubscription(
            instance: self.presenceInstance,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            roomStore: self.roomStore,
            connectionCoordinator: self.connectionCoordinator,
            delegate: delegate
        )

        self.presenceSubscription = presenceSub

        self.presenceInstance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: { [unowned presenceSub] eventID, headers, data in
                presenceSub.handleEvent(eventId: eventID, headers: headers, data: data)
            },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(presenceSubscription: nil, error: error)
                )
            }
        )
    }

    func establishCursorSubscription() {
        let userCursorSubscriptionPath = "/cursors/\(PCCursorType.read.rawValue)/users/\(self.pathFriendlyId)"
        let cursorSubscriptionRequestOptions = PPRequestOptions(
            method: HTTPMethod.SUBSCRIBE.rawValue,
            path: userCursorSubscriptionPath
        )

        var cursorResumableSub = PPResumableSubscription(
            instance: self.cursorsInstance,
            requestOptions: cursorSubscriptionRequestOptions
        )

        let cursorSub = PCCursorSubscription(
            resumableSubscription: cursorResumableSub,
            cursorStore: cursorStore,
            connectionCoordinator: self.connectionCoordinator,
            logger: self.cursorsInstance.logger,
            initialStateHandler: { [unowned self] err in
                if let err = err {
                    self.cursorsInstance.logger.log(err.localizedDescription, logLevel: .debug)
                }
                // TODO: Should the connection coordinator get the error here?
                // Do we care if a single (in this weird case, only the last to be received)
                // basic cursor can't be enriched with information about its room and/or user?
                // We probably just want to log something
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(cursorSubscription: self.cursorSubscription, error: nil)
                )
            }
        )

        self.cursorSubscription = cursorSub

        self.cursorsInstance.subscribeWithResume(
            with: &cursorResumableSub,
            using: cursorSubscriptionRequestOptions,
            onEvent: { [unowned cursorSub] eventID, headers, data in
                cursorSub.handleEvent(eventId: eventID, headers: headers, data: data)
            },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(cursorSubscription: nil, error: error)
                )
            }
        )
    }
}
