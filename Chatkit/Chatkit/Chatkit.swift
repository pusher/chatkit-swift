import Foundation
import CoreData
import PusherPlatform

public class Chatkit {
    
    //MARK: - Properties
    
    public let instanceLocator: String
    public let tokenProvider: PPTokenProvider
    
    private let persistenceController: PersistenceController
    
    //MARK: - Initializers
    
    public init(instanceLocator: String, tokenProvider: PPTokenProvider) throws {
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
        
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))]) else {
            throw PersistenceError.objectModelNotFound
        }
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        self.persistenceController = try PersistenceController(model: model, storeDescriptions: [storeDescription])
    }
    
}
