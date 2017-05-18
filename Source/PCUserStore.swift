import Foundation
import PusherPlatform

public class PCUserStore {

    public internal(set) var users: Set<PCUser>
    public let app: App

    public init(users: Set<PCUser> = [], app: App) {
        self.users = users
        self.app = app
    }

    public func user(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        self.findOrGetUser(id: id, completionHander: completionHandler)
    }

    public func add(_ user: PCUser){
        self.users.insert(user)
    }

    public func remove(id: Int) -> PCUser? {
        guard let userToRemove = self.users.first(where: { $0.id == id }) else {
            return nil
        }

        return self.users.remove(userToRemove)
    }

    internal func findOrGetUser(id: Int, completionHander: @escaping (PCUser?, Error?) -> Void) {
        if let user = self.users.first(where: { $0.id == id }) {
            completionHander(user, nil)
        } else {
            self.getUser(id: id) { user, err in
                guard let user = user, err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHander(nil, err!)
                    return
                }

                self.users.insert(user)
                completionHander(user, nil)
            }
        }
    }

    internal func getUser(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        let path = "/\(ChatManager.namespace)/users/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let userPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
                    completionHandler(user, nil)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { err in
                completionHandler(nil, err)
            }
        )
    }

}
