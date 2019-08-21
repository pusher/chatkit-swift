import Foundation
import PusherPlatform

public struct RoomProvider {
    
    // MARK: - Properties
    
    private let store: Store<RoomEntity>
    
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
    
    public func rooms(of user: User) -> [Room]? {
        let predicate = NSPredicate(format: "%@ IN %K", user.objectID, #keyPath(RoomEntity.members))
        return self.store.objects(for: predicate)
    }
    
    public func rooms(createdBy user: User) -> [Room]? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(RoomEntity.creator), user.objectID)
        return self.store.objects(for: predicate)
    }
    
}
