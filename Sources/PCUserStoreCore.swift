import Foundation

public final class PCUserStoreCore {
    fileprivate let userStoreQueue = DispatchQueue(label: "com.pusher.chatkit.user-store-core")

    private var users: Set<PCUser>

    init(users: Set<PCUser> = []) {
        self.users = users
    }

    func copy() -> Set<PCUser> {
        return userStoreQueue.sync {
            return Set(self.users)
        }
    }

    func find(_ id: String) -> PCUser? {
        return self.userStoreQueue.sync {
            return users.first { user in
                user.id == id
            }
        }
    }

    func addOrMerge(_ user: PCUser) -> PCUser {
        return self.userStoreQueue.sync {
            let insertResult = self.users.insert(user)

            if !insertResult.inserted {
                // If a user already exists in the store with a matching id then merge
                // the properties of the two user objects
                return insertResult.memberAfterInsert.updateWithPropertiesOf(user)
            } else {
                return insertResult.memberAfterInsert
            }
        }
    }

    func remove(id: String) -> PCUser? {
        return self.userStoreQueue.sync {
            guard let userToRemove = self.users.first(where: { $0.id == id }) else {
                return nil
            }

            return self.users.remove(userToRemove)
        }
    }
}
