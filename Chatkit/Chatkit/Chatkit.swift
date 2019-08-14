import Foundation
import CoreData
import PusherPlatform

public class Chatkit {
    
    // MARK: - Properties
    
    public let instanceLocator: String
    public let tokenProvider: PPTokenProvider
    public let logger: Logger?
    
    private let persistenceController: PersistenceController
    
    // MARK: - Initializers
    
    public init(instanceLocator: String, tokenProvider: PPTokenProvider, logger: Logger? = nil) throws {
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
        self.logger = logger
        
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))]) else {
            logger?.log("Failed to load Chatkit data model.", logLevel: .error)
            throw PersistenceError.objectModelNotFound
        }
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        self.persistenceController = try PersistenceController(model: model, storeDescriptions: [storeDescription], logger: logger) { error in
            if let error = error {
                logger?.log("Failed to load persistent stores with error: \(error.localizedDescription).", logLevel: .error)
            }
        }
    }
    
}
