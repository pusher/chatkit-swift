import PusherPlatform

@objc public class ChatManager: NSObject {
    static public let namespace = "chat_api/v1"

    public let app: App
    public internal(set) var userSubscription: PCUserSubscription? = nil

    public var currentUser: PCCurrentUser? {
        get {
            return self.userSubscription?.currentUser
        }
    }

    let userStore: PCGlobalUserStore
    public var users: Set<PCUser> {
        get {
            return self.userStore.users
        }
    }

    // TODO: _remove_ userId should just be inferred from user token
    public var userId: Int? = nil

    public internal(set) var presenceSubscription: PCPresenceSubscription? = nil

    public init(
        id: String,
        app: App? = nil,
        authorizer: PPAuthorizer? = nil,
        logger: PPLogger = PPDefaultLogger(),
        baseClient: PPBaseClient? = nil
    ) {
        self.app = app ?? App(id: id, authorizer: authorizer, client: baseClient, logger: logger)
        self.userStore = PCGlobalUserStore(app: self.app)
    }

    public func addConnectCompletionHandler(completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
        guard let userSub = userSubscription else {
            self.app.logger.log("userSubscription is nil so unable to add a connectCompletionHandler", logLevel: .debug)
            return
        }

        userSub.connectCompletionHandlers.append(completionHandler)
    }

    public func connect(
        userId: Int,
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        self.userId = userId
        let path = "/\(ChatManager.namespace)/users/\(userId)"

        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        self.userSubscription = PCUserSubscription(
            app: self.app,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            delegate: delegate,
            connectCompletionHandler: { user, error in
                guard let cUser = user else {
                    completionHandler(nil, error)
                    return
                }

                self.setupPresenceSubscription(userId: userId, delegate: delegate)

                completionHandler(cUser, nil)
            }
        )

        // TODO: Fix this stuff

        self.app.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            //            onOpening: onOpening,
            //            onOpen: onOpen,
            //            onResuming: onResuming,
            onEvent: self.userSubscription!.handleEvent,
            onEnd: { statusCode, headers, info in
                print("ENDED")
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    //    fileprivate func onUserSubscriptionStateChange(newState: ) {
    //        self.delegate?.userSubscriptionStateChanged(from: <#T##PCUserSubscriptionState#>, to: <#T##PCUserSubscriptionState#>)
    //    }

    public func setupPresenceSubscription(userId: Int, delegate: PCChatManagerDelegate) {
        let path = "/\(ChatManager.namespace)/users/\(userId)/presence"

        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        self.presenceSubscription = PCPresenceSubscription(
            app: self.app,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            delegate: delegate
        )

        self.app.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: self.presenceSubscription!.handleEvent
        )
    }

}
