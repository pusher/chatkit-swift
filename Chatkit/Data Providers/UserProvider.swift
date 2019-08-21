import Foundation
import PusherPlatform

public struct UserProvider {
    
    // MARK: - Properties
    
    private let store: Store<UserEntity>
    
    // MARK: - Accessors
    
    public var users: [User]? {
        return self.store.objects()
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func user(with identifier: String) -> User? {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(UserEntity.identifier), identifier)
        return self.store.object(for: predicate)
    }
    
    public func users(sharingRoomWith user: User) -> [User]? {
        let predicate = NSPredicate(format: "ANY %K IN SUBQUERY(%K, $room, %@ IN $room.%K) AND SELF != %@", #keyPath(UserEntity.room), #keyPath(UserEntity.room), user.objectID, #keyPath(RoomEntity.members), user.objectID)
        return self.store.objects(for: predicate)
    }
    
}
