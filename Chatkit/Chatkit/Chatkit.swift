import Foundation
import CoreData
import PusherPlatform

public class Chatkit {
    
    // MARK: - Properties
    
    public let logger: PPLogger
    
    public let roomProvider: RoomProvider
    public let userProvider: UserProvider
    public let messageProvider: MessageProvider
    
    private let persistenceController: PersistenceController
    private let networkingController: NetworkingController
    
    // MARK: - Accessors
    
    public var instanceLocator: String {
        return self.networkingController.instanceLocator
    }
    
    public var tokenProvider: PPTokenProvider {
        return self.networkingController.tokenProvider
    }
    
    public var connectionStatus: ConnectionStatus {
        return self.networkingController.connectionStatus
    }
    
    // MARK: - Initializers
    
    public init(instanceLocator: String, tokenProvider: PPTokenProvider, logger: PPLogger = PPDefaultLogger()) throws {
        self.logger = logger
        
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle.current]) else {
            logger.log("Failed to load Chatkit data model.", logLevel: .error)
            throw PersistenceError.objectModelNotFound
        }
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        self.persistenceController = try PersistenceController(model: model, storeDescriptions: [storeDescription], logger: logger) { error in
            if let error = error {
                logger.log("Failed to load persistent stores with error: \(error.localizedDescription).", logLevel: .error)
            }
        }
        
        let eventParser = ModularEventParser(logger: self.logger)
        eventParser.register(parser: ChatEventParser(persistenceController: self.persistenceController, logger: self.logger), for: .chat, with: .version6)
        
        self.networkingController = try NetworkingController(instanceLocator: instanceLocator, tokenProvider: tokenProvider, eventParser: eventParser, logger: self.logger)
        
        self.roomProvider = RoomProvider(persistenceController: self.persistenceController)
        self.userProvider = UserProvider(persistenceController: self.persistenceController)
        self.messageProvider = TestDataFactory.createMessageProvider()
    }
    
    // MARK: - Public methods
    
    public func connect(completionHandler: CompletionHandler? = nil) {
        self.networkingController.connect(completionHandler: completionHandler)
    }
    
    public func disconnect() {
        self.networkingController.disconnect()
    }
    
}
