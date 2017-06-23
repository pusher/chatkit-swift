import Foundation

public class PCUserStoreCore {
    fileprivate let userStoreQueue = DispatchQueue(label: "com.pusher.chat-api.user-store-core")

    public internal(set) var users: Set<PCUser>

    init(users: Set<PCUser> = []) {
        self.users = users
    }

    func addOrMerge(_ user: PCUser) -> PCUser {
        let insertResult = users.insert(user)

        if !insertResult.inserted {
            // If a user already exists in the store with a matching id then merge
            // the properties of the two user objects
            return insertResult.memberAfterInsert.updateWithPropertiesOfUser(user)
        } else {
            return insertResult.memberAfterInsert
        }
    }

    func remove(id: String) -> PCUser? {
        guard let userToRemove = self.users.first(where: { $0.id == id }) else {
            return nil
        }

        return self.users.remove(userToRemove)
    }
}
