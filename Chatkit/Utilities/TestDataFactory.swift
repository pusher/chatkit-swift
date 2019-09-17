import Foundation
import CoreData
import PusherPlatform

public struct TestDataFactory {
    
    static var persistenceController: PersistenceController = {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.current])!
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        storeDescription.shouldAddStoreAsynchronously = false
        
        return try! PersistenceController(model: model, storeDescriptions: [storeDescription])
    }()
    
    public static func createMessageTestDataProvider() -> MessageTestDataProvider {
        let persistenceController = TestDataFactory.persistenceController
        return MessageTestDataProvider(persistenceController: persistenceController)
    }
    
    public static func createMessageTestDataDriver() -> MessageTestDataDriver {
        let testDataProvider = TestDataFactory.createMessageTestDataProvider()
        return MessageTestDataDriver(testDataProvider: testDataProvider)
    }
    
    public static func createMessageProvider() -> MessageProvider {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.current])!
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        storeDescription.shouldAddStoreAsynchronously = false
        
        let persistenceController = try! PersistenceController(model: model, storeDescriptions: [storeDescription])
    
        let messageTestDataDriver = MessageTestDataDriver(testDataProvider: MessageTestDataProvider(persistenceController: persistenceController))
        
        return MessageProvider(roomIdentifier: "blah", persistenceController: persistenceController, chatkitClient: messageTestDataDriver)
    }
}
