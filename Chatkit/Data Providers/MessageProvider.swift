import Foundation
import CoreData
import PusherPlatform

public class MessageProvider: NSObject, DataProvider {
    
    // MARK: - Properties
    
    public private(set) var isFetchingOlderMessages: Bool
    public let logger: PPLogger?
    
    public weak var delegate: MessageProviderDelegate?
    
    private let persistenceController: PersistenceController
    private let driver: MessageTestDataDriver
    private let roomIdentifier: String
    private let fetchedResultsController: FetchedResultsController<MessageEntity>
    
    // MARK: - Accessors
    
    public var numberOfAvailableMessages: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(roomIdentifier: String, persistenceController: PersistenceController, driver: MessageTestDataDriver, logger: PPLogger? = nil) {
        self.persistenceController = persistenceController
        self.driver = driver
        self.roomIdentifier = roomIdentifier
        self.isFetchingOlderMessages = false
        self.logger = logger
        
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room.identifier), self.roomIdentifier)
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: true)]
        let context = self.persistenceController.mainContext
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: sortDescriptors, predicate: predicate, context: context)
        
        super.init()
        
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - Public methods
    
    public func message(at index: Int) -> Message? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
    }
    
    public func fetchOlderMessages(numberOfMessages: UInt, completionHandler: ((Error?) -> Void)? = nil) {
        guard !self.isFetchingOlderMessages else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.isFetchingOlderMessages = true
        
        let message = self.message(at: 0)?.identifier
        
        self.driver.fetchMessages(room: self.roomIdentifier, from: message, order: "older", amount: numberOfMessages) { _ in
            self.isFetchingOlderMessages = false
        }
    }
    
}

extension MessageProvider: FetchedResultsControllerDelegate {
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        self.delegate?.messageProvider(self, didReceiveMessagesWithRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let message = try? object.snapshot() else {
            return
        }
        
        self.delegate?.messageProvider(self, didChangeMessageAtIndex: index, previousValue: message)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let message = try? object.snapshot() else {
            return
        }
        
        self.delegate?.messageProvider(self, didDeleteMessageAtIndex: index, previousValue: message)
    }
    
}

// MARK: - Delegate

public protocol MessageProviderDelegate: class {
    
    func messageProvider(_ messageProvider: MessageProvider, didReceiveMessagesWithRange range: Range<Int>)
    func messageProvider(_ messageProvider: MessageProvider, didChangeMessageAtIndex index: Int, previousValue: Message)
    func messageProvider(_ messageProvider: MessageProvider, didDeleteMessageAtIndex index: Int, previousValue: Message)
    
}
