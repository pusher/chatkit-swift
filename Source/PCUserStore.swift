import Foundation
import PusherPlatform

public class PCUserStore {

    // TODO: Probably need to add a reader-writer queue for access to the users set

    public internal(set) var users: Set<PCUser>
    let app: App

    init(users: Set<PCUser> = [], app: App) {
        self.users = users
        self.app = app
    }

    public func user(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        self.findOrGetUser(id: id, completionHander: completionHandler)
    }

    func addOrMerge(_ user: PCUser) -> PCUser {
        let insertResult = self.users.insert(user)

        if !insertResult.inserted {
            // If a user already exists in the store with a matching id then merge
            // the properties of the two user objects
            return insertResult.memberAfterInsert.updateWithPropertiesOfUser(user)
        } else {
            return insertResult.memberAfterInsert
        }
    }

    func remove(id: Int) -> PCUser? {
        guard let userToRemove = self.users.first(where: { $0.id == id }) else {
            return nil
        }

        return self.users.remove(userToRemove)
    }

    func findOrGetUser(id: Int, completionHander: @escaping (PCUser?, Error?) -> Void) {
        if let user = self.users.first(where: { $0.id == id }) {
            completionHander(user, nil)
        } else {
            self.getUser(id: id) { user, err in
                guard let user = user, err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHander(nil, err!)
                    return
                }

                let userToReturn = self.addOrMerge(user)
                completionHander(userToReturn, nil)
            }
        }
    }

    func getUser(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
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

    func handleInitialPresencePayloads(_ payloads: [PCPresencePayload]) {
        payloads.forEach { payload in
            self.findOrGetUser(id: payload.userId) { user, err in
                guard let user = user, err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    return
                }

                user.presenceState = payload.state
                user.lastSeenAt = payload.lastSeenAt
            }
        }
    }

    // This will do the de-duping of userIds
    func fetchUsersWithIds(_ userIds: [Int], completionHandler: (([PCUser]?, Error?) -> Void)? = nil) {
        let uniqueUserIds = Array(Set<Int>(userIds))
        let userIdsString = uniqueUserIds.map { String($0) }.joined(separator: ",")

        let path = "/\(ChatManager.namespace)/users"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
        generalRequest.addQueryItems([URLQueryItem(name: "user_ids", value: userIdsString)])

        // We want this to complete quickly, whether it succeeds or not
        generalRequest.retryStrategy = PPDefaultRetryStrategy(maxNumberOfAttempts: 1)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    let err = PCError.failedToDeserializeJSON(data)
                    self.app.logger.log(
                        "Error fetching user information: \(err.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler?(nil, err)
                    return
                }

                guard let userPayloads = jsonObject as? [[String: Any]] else {
                    let err = PCError.failedToCastJSONObjectToDictionary(jsonObject)
                    self.app.logger.log(
                        "Error fetching user information: \(err.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler?(nil, err)
                    return
                }

                let users = userPayloads.flatMap { userPayload -> PCUser? in
                    do {
                        let user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
                        self.addOrMerge(user)
                        return user
                    } catch let err {
                        self.app.logger.log("Error fetching user information: \(err.localizedDescription)", logLevel: .debug)
                        return nil
                    }
                }
                completionHandler?(users, nil)
            },
            onError: { err in
                self.app.logger.log("Error fetching user information: \(err.localizedDescription)", logLevel: .debug)
            }
        )
    }

    func initialFetchOfUsersWithIds(_ userIds: [Int], completionHandler: (([PCUser]?, Error?) -> Void)? = nil) {
        self.fetchUsersWithIds(userIds)
    }

}
