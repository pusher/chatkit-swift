import Foundation
import PusherPlatform

final public class PCRoomUserStore {

    public var users: Set<PCUser> {
        get {
            return self.userStoreCore.users
        }
    }

    public internal(set) var userStoreCore: PCUserStoreCore

    init(userStoreCore: PCUserStoreCore = PCUserStoreCore()) {
        self.userStoreCore = userStoreCore
    }

    @discardableResult
    func addOrMerge(_ user: PCUser) -> PCUser {
        return self.userStoreCore.addOrMerge(user)
    }

    @discardableResult
    func remove(id: String) -> PCUser? {
        return self.userStoreCore.remove(id: id)
    }

}
