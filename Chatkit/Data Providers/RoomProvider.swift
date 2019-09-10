import Foundation
import PusherPlatform

public struct RoomProvider: DataProvider {
    
    // MARK: - Properties
    
    let store: Store<RoomEntity>
    
    // MARK: - Accessors
    
    public var rooms: [Room]? {
        return self.store.objects()
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func room(with identifier: String) -> Room? {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(RoomEntity.identifier), identifier)
        return self.store.object(for: predicate)
    }
    
    public func room(for message: Message) -> Room? {
        let predicate = NSPredicate(format: "%@ IN %K", message.objectID, #keyPath(RoomEntity.messages))
        return self.store.object(for: predicate)
    }
    
}
