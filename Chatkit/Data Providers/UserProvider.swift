import Foundation
import PusherPlatform

public class UserProvider {
    
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
        // TODO: Implement
        return nil
    }
    
    public func users(sharingRoomWith user: User) -> [User]? {
        // TODO: Implement
        return nil
    }
    
}
