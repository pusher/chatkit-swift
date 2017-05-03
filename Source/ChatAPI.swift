import PusherPlatform

@objc public class ChatAPI: NSObject {
    static public let namespace = "chat_api"

    public let app: App
    public var options: PCOptions?
    public var delegate: PCDelegate?

    // TODO: _remove_ userId should probs just be inferred from user token
    public var userId: Int? = nil

    public internal(set) var userSubscription: PCUserSubscription? = nil

    // TODO: Do we need to should store the PCCurrentUser as a property here?

    public var currentUser: PCCurrentUser? = nil

    public init(
        id: String,
        options: PCOptions? = nil,
        delegate: PCDelegate? = nil,
        authorizer: Authorizer? = nil,
        baseClient: BaseClient? = nil

        // TODO: Make this possible by fixing init in pusher-platform-swift for App
//        logger: PPLogger? = nil
    ) {
        self.app = App(id: id, authorizer: authorizer, client: baseClient)
        self.options = options
        self.delegate = delegate
    }

    public func addConnectCompletionHandler(completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
        guard let userSub = userSubscription else {
            print("No userSubscription so couldn't add connectCompletionHandler")
            return
        }

        userSub.connectCompletionHandlers.append(completionHandler)
    }

    // TODO: Maybe move PCDelegate to connect callsite
    // TODO: Maybe rename PCDelegate to PCUserSubscriptionDelegate

    public func connect(userId: Int, completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
        self.userId = userId
        let path = "/\(ChatAPI.namespace)/users/\(userId)"

        let subscribeRequest = PPRequestOptions(method: "SUBSCRIBE", path: path)

        var resumableSub = ResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        self.userSubscription = PCUserSubscription(
            app: self.app,
            delegate: self.delegate,
            resumableSubscription: resumableSub,
            connectCompletionHandler: { user, error in
                if user != nil {
                    self.currentUser = user
                }

                completionHandler(user, error)
            }
        )

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
}

extension ChatAPI {
    // TODO: Should a user creation function be available in the Swift lib?

    public func createUser(name: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let randomString = NSUUID().uuidString

        let userObject: [String: Any] = ["name": name, "id": randomString]

        guard JSONSerialization.isValidJSONObject(userObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(userObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(userObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/users"

        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let json = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                guard let id = json["id"] as? Int else {
                    completionHandler(nil, PCError.userIdNotFoundInResponseJSON(json))
                    return
                }

                completionHandler(id, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }
}

public struct PCOptions {
    
}
