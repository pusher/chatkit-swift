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
    public internal(set) var cursorSubscription: PCCursorSubscription?

    private let chatkitBeamsTokenProviderInstance: Instance
    let instance: Instance
    let filesInstance: Instance
    let cursorsInstance: Instance
    let presenceInstance: Instance
    let delegate: PCChatManagerDelegate

    let connectionCoordinator: PCConnectionCoordinator

    public init(
        id: String,
        pathFriendlyID: String,
        instance: Instance,
        chatkitBeamsTokenProviderInstance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
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
        self.cursorsInstance = cursorsInstance
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

    func establishCursorSubscription(initialStateHandler: @escaping (InitialStateResult<PCCursor>) -> Void) {
        let userCursorSubscriptionPath = "/cursors/\(PCCursorType.read.rawValue)/users/\(self.pathFriendlyID)"
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
            logger: self.cursorsInstance.logger,
            onNewReadCursorHook: { [weak delegate] cursor in
                delegate?.onNewReadCursor(cursor)
            },
            initialStateHandler: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }

                switch result {
                case .error(let err):
                    strongSelf.cursorsInstance.logger.log(err.localizedDescription, logLevel: .debug)

                    // TODO: Should the connection coordinator get the error here?
                    // Do we care if a single (in this weird case, only the last to be received)
                    // basic cursor can't be enriched with information about its room and/or user?
                    // We probably just want to log something
                    strongSelf.connectionCoordinator.connectionEventCompleted(
                        PCConnectionEvent(cursorSubscription: strongSelf.cursorSubscription, error: nil)
                    )
                case .success(_, _):
                    // This needs to be called before the connection event is sent to the
                    // connectionCoordinator to ensure that the state of the cursor store
                    // is accurate before the currentUser object can be yielded to the
                    // end-user's code
                    initialStateHandler(result)

                    strongSelf.connectionCoordinator.connectionEventCompleted(
                        PCConnectionEvent(cursorSubscription: strongSelf.cursorSubscription, error: nil)
                    )
                }
            }
        )

        self.cursorSubscription = cursorSub

        self.cursorsInstance.subscribeWithResume(
            with: &cursorResumableSub,
            using: cursorSubscriptionRequestOptions,
            onEvent: { [unowned cursorSub] eventID, headers, data in
                cursorSub.handleEvent(eventID: eventID, headers: headers, data: data)
            },
            onError: { [unowned self] error in
                self.connectionCoordinator.connectionEventCompleted(
                    PCConnectionEvent(cursorSubscription: nil, error: error)
                )
            }
        )
    }
}
