import Foundation
import PusherPlatform

class LegacyUserProvider {
    
    // MARK: - Properties
    
    let store: Store<UserEntity>
    
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
    
}
