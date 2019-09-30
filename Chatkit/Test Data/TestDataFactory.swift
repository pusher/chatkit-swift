import Foundation
import CoreData
import PusherPlatform

public class TestDataFactory {
    
    static let persistenceController: PersistenceController = {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.current])!
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        storeDescription.shouldAddStoreAsynchronously = false
        
        return try! PersistenceController(model: model, storeDescriptions: [storeDescription])
    }()
    
    public static func createRoomListProvider() -> RoomListProvider {
        return RoomListProvider()
    }
    
    public static func createUserProvider() -> UserProvider {
        return UserProvider()
    }
    
    public static func createMessageProvider(for room: Room) -> MessageProvider {
        return MessageProvider(room: room, persistenceController: TestDataFactory.persistenceController)
    }
    
}
