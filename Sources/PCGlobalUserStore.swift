import Foundation
import PusherPlatform

public final class PCGlobalUserStore {

    public var users: Set<PCUser> {
        return self.userStoreCore.users
    }

    public internal(set) var userStoreCore: PCUserStoreCore
    unowned let instance: Instance
    var onUserStoredHooks: [(PCUser) -> Void]

    init(userStoreCore: PCUserStoreCore = PCUserStoreCore(), instance: Instance) {
        self.userStoreCore = userStoreCore
        self.instance = instance
        self.onUserStoredHooks = []
    }

    public func user(id: String, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        self.findOrGetUser(id: id, completionHandler: completionHandler)
    }

    func addOrMerge(_ user: PCUser) -> PCUser {
        let storedUser = self.userStoreCore.addOrMerge(user)
        self.onUserStoredHooks.forEach { hook in
            hook(storedUser)
        }
        return storedUser
    }

    func remove(id: String) -> PCUser? {
        return self.userStoreCore.remove(id: id)
    }

    func findOrGetUser(id: String, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        if let user = self.userStoreCore.users.first(where: { $0.id == id }) {
            completionHandler(user, nil)
        } else {
            self.getUser(id: id) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil getUser completes in the user store")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHandler(nil, err!)
                    return
                }

                let userToReturn = strongSelf.addOrMerge(user)
                completionHandler(userToReturn, nil)
            }
        }
    }

    func getUser(id: String, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        let path = "/users/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.instance.requestWithRetry(
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
                    self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { err in
                completionHandler(nil, err)
            }
        )
    }

    // TODO: Need a version of this that first checks the userStore for any of the userIDs
    // provided and then only makes a request to fetch the user information for the userIDs
    // that aren't known about. This would be used in the createRoom callback and the
    // addedToRoom parsing function

    // This will do the de-duping of userIDs
    func fetchUsersWithIDs(_ userIDs: Set<String>, completionHandler: (([PCUser]?, Error?) -> Void)? = nil) {
        guard userIDs.count > 0 else {
            self.instance.logger.log("Requested to fetch users for a list of user ids which was empty", logLevel: .debug)
            completionHandler?([], nil)
            return
        }

        let path = "/users_by_ids"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
        generalRequest.addQueryItems(userIDs.map{URLQueryItem(name: "id", value: $0)})

        // We want this to complete quickly, whether it succeeds or not
        generalRequest.retryStrategy = PPDefaultRetryStrategy(maxNumberOfAttempts: 1)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    let err = PCError.failedToDeserializeJSON(data)
                    self.instance.logger.log(
                        "Error fetching user information: \(err.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler?(nil, err)
                    return
                }

                guard let userPayloads = jsonObject as? [[String: Any]] else {
                    let err = PCError.failedToCastJSONObjectToDictionary(jsonObject)
                    self.instance.logger.log(
                        "Error fetching user information: \(err.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler?(nil, err)
                    return
                }

                let users = userPayloads.compactMap { userPayload -> PCUser? in
                    do {
                        let user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
                        let addedOrUpdatedUser = self.addOrMerge(user)
                        return addedOrUpdatedUser
                    } catch let err {
                        self.instance.logger.log("Error fetching user information: \(err.localizedDescription)", logLevel: .debug)
                        return nil
                    }
                }
                completionHandler?(users, nil)
            },
            onError: { err in
                self.instance.logger.log("Error fetching user information: \(err.localizedDescription)", logLevel: .debug)
                completionHandler?(nil, err)
            }
        )
    }

    func initialFetchOfUsersWithIDs(_ userIDs: Set<String>, completionHandler: (([PCUser]?, Error?) -> Void)? = nil) {
        self.fetchUsersWithIDs(userIDs, completionHandler: completionHandler)
    }
}
