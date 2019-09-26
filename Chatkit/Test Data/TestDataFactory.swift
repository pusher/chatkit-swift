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
    
    public static func createJoinedRoomListProvider() -> JoinedRoomListProvider {
        return JoinedRoomListProvider(persistenceController: TestDataFactory.persistenceController)
    }
    
    public static func createMessageProvider(for room: Room) -> MessageProvider {
        return MessageProvider(room: room, persistenceController: TestDataFactory.persistenceController)
    }
    
}
