import Foundation
import PusherPlatform

public class RoomProvider {
    
    // MARK: - Properties
    
    private let store: Store<RoomEntity>
    
    // MARK: - Accessors
    
    public var rooms: [Room]? {
        // TODO: Implement
        return nil
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func room(with identifier: String) -> Room? {
        // TODO: Implement
        return nil
    }
    
    public func room(for message: Message) -> Room? {
        // TODO: Implement
        return nil
    }
    
    public func rooms(of user: User) -> [Room]? {
        // TODO: Implement
        return nil
    }
    
}
