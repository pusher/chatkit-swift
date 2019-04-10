import Foundation
import PusherPlatform

public final class PCBasicCurrentUser {
    public let id: String
    public let pathFriendlyID: String

    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let cursorStore: PCCursorStore

    public internal(set) var userSubscription: PCUserSubscription?
    public internal(set) var presenceSubscription: PCPresenceSubscription?

    private let chatkitBeamsTokenProviderInstance: Instance
    let instance: Instance
    let filesInstance: Instance
    let presenceInstance: Instance
    let delegate: PCChatManagerDelegate

    let connectionCoordinator: PCConnectionCoordinator

    public init(
        id: String,
        pathFriendlyID: String,
        instance: Instance,
        chatkitBeamsTokenProviderInstance: Instance,
        filesInstance: Instance,
        presenceInstance: Instance,
        connectionCoordinator: PCConnectionCoordinator,
        delegate: PCChatManagerDelegate,
        userStore: PCGlobalUserStore? = nil,
        roomStore: PCRoomStore? = nil,
        cursorStore: PCCursorStore? = nil
    ) {
        self.id = id
        self.pathFriendlyID = pathFriendlyID
        self.instance = instance
        self.chatkitBeamsTokenProviderInstance = chatkitBeamsTokenProviderInstance
        self.filesInstance = filesInstance
        self.presenceInstance = presenceInstance
        self.connectionCoordinator = connectionCoordinator
        self.delegate = delegate

        let us = userStore ?? PCGlobalUserStore(instance: instance)
        let rs = roomStore ?? PCRoomStore(rooms: PCSynchronizedArray<PCRoom>(), instance: instance)
        self.userStore = us
        self.roomStore = rs

        self.cursorStore = cursorStore ?? PCCursorStore(
            instance: instance,
            roomStore: rs,
            userStore: us
        )
    }

    func establishUserSubscription(
        initialStateHandler: @escaping ((roomsPayload: [[String: Any]], cursorsPayload: [[String: Any]], currentUserPayload: [String: Any])) -> Void
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
            presenceInstance: self.presenceInstance,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            cursorStore: self.cursorStore,
            delegate: self.delegate,
            userID: id,
            pathFriendlyUserID: pathFriendlyID,
            connectionCoordinator: connectionCoordinator,
            initialStateHandler: initialStateHandler
        )

        self.userSubscription = userSub

        // TODO: Decide what to do with onEnd
        self.instance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: { [unowned userSub] eventID, headers, data in
                userSub.handleEvent(eventID: eventID, headers: headers, data: data)
            },
            onEnd: { _, _, _ in },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(currentUser: nil, error: error)
                )
            }
        )
    }

    func establishPresenceSubscription() {
        // If a presenceSubscription already exists then we want to create a new one
        // so we first close the existing subscription, if it was still open
        if let presSub = self.presenceSubscription {
            presSub.end()
            self.presenceSubscription = nil
        }

        let path = "/users/\(self.pathFriendlyID)/register"
        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            instance: self.presenceInstance,
            requestOptions: subscribeRequest
        )

        let presenceSub = PCPresenceSubscription(resumableSubscription: resumableSub)
        self.presenceSubscription = presenceSub

        self.presenceInstance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onOpen: { [unowned self, unowned presenceSub] in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(presenceSubscription: presenceSub, error: nil)
                )
            },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(presenceSubscription: nil, error: error)
                )
            }
        )
    }
}
