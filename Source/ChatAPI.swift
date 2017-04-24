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

        var resumableSub = ResumableSubscription(
            app: self.app,
            path: path
            //            onOpening: onUserSubscriptionStateChange(),
            //            onOpen: onOpen,
            //            onResuming: onResuming,
            //            onEnd: onEnd,
            //            onError: onError
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

        let subscribeRequest = SubscribeRequest(path: path)

        self.app.subscribeWithResume(
            resumableSubscription: &resumableSub,
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
            completionHandler(nil, ServiceError.invalidJSONObjectAsData(userObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userObject, options: []) else {
            completionHandler(nil, ServiceError.failedToJSONSerializeData(userObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/users"

        let generalRequest = GeneralRequest(method: HttpMethod.POST.rawValue, path: path, body: data)

        self.app.request(using: generalRequest) { result in
            guard let data = result.value else {
                completionHandler(nil, result.error!)
                return
            }

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
        }
    }
}

public struct PCOptions {
    
}
