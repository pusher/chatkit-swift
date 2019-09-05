import Foundation
import PusherPlatform

public struct MessageProvider {
    
    // MARK: - Properties
    
    private let store: Store<MessageEntity>
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func message(with identifier: String) -> Message? {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(MessageEntity.identifier), identifier)
        return self.store.object(for: predicate)
    }
    
    public func messages(in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room), room.objectID)
        return self.store.objects(for: predicate)
    }
    
}
