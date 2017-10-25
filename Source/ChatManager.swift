import Foundation
import PusherPlatform

@objc public class ChatManager: NSObject {
    public static let namespace = "chatkit/v1"

    public let instance: Instance
    public internal(set) var userSubscription: PCUserSubscription?

    public var currentUser: PCCurrentUser? {
        return self.userSubscription?.currentUser
    }

    let userStore: PCGlobalUserStore

    // TODO: Do we need this here? Should it instead just live on the PCCurrentUser?
    public var users: Set<PCUser> {
        return self.userStore.users
    }

    public init(
        instanceId: String,
        tokenProvider: PPTokenProvider,
        logger: PPLogger = PPDefaultLogger(),
        baseClient: PPBaseClient? = nil
    ) {
        (tokenProvider as? PCTokenProvider)?.logger = logger
        
        self.instance = Instance(
            instanceId: instanceId,
            serviceName: "chatkit",
            serviceVersion: "v1",
            tokenProvider: tokenProvider,
            client: baseClient,
            logger: logger
        )

        self.userStore = PCGlobalUserStore(instance: self.instance)
    }

    public func addConnectCompletionHandler(completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
        guard let userSub = userSubscription else {
            self.instance.logger.log("userSubscription is nil so unable to add a connectCompletionHandler", logLevel: .debug)
            return
        }

        userSub.connectCompletionHandlers.append(completionHandler)
    }

    public func connect(
        delegate: PCChatManagerDelegate,
        completionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        let path = "/users"
        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            instance: self.instance,
            requestOptions: subscribeRequest
        )

        self.userSubscription = PCUserSubscription(
            instance: self.instance,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            delegate: delegate,
            connectCompletionHandler: { user, error in
                guard let cUser = user else {
                    completionHandler(nil, error)
                    return
                }

                completionHandler(cUser, nil)
            }
        )

        // TODO: Fix this stuff

        self.instance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: self.userSubscription!.handleEvent,
            onEnd: { _, _, _ in },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    //    fileprivate func onUserSubscriptionStateChange(newState: ) {
    //        self.delegate?.userSubscriptionStateChanged(from: <#T##PCUserSubscriptionState#>, to: <#T##PCUserSubscriptionState#>)
    //    }
}
