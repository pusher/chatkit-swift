import Foundation
import CoreData
import PusherPlatform

public class RoomDetailsProvider: DataProvider {
    
    // MARK: - Properties
    
    public let roomIdentifier: String
    public private(set) var realTimeState: RealTimeCollectionState
    public private(set) var pagedState: PagedCollectionState
    
    public weak var delegate: RoomDetailsProviderDelegate? {
        didSet {
            if delegate == nil {
                self.messageFactory.stopReceivingNewMessages()
            }
            else {
                self.messageFactory.startReceivingNewMessages()
            }
        }
    }
    
    private let roomManagedObjectID: NSManagedObjectID
    private let fetchedResultsController: FetchedResultsController<MessageEntity>
    private let messageFactory: MessageEntityFactory
    
    // MARK: - Accessors
    
    public var numberOfMessages: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(room: Room, currentUser: User, persistenceController: PersistenceController) {
        self.roomIdentifier = room.identifier
        self.realTimeState = .initializing
        self.pagedState = .initializing
        
        self.roomManagedObjectID = room.objectID
        self.messageFactory = MessageEntityFactory(roomID: self.roomManagedObjectID,
                                                   currentUserManagedObjectID: currentUser.objectID,
                                                   persistenceController: persistenceController)
        
        let context = persistenceController.mainContext
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room), self.roomManagedObjectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                return .orderedSame
            }
            
            return NSNumber(value: lhs).compare(NSNumber(value: rhs))
        }
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
        self.fetchedResultsController.delegate = self
        
        self.fetchData()
    }
    
    // MARK: - Public methods
    
    public func message(at index: Int) -> Message? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
    }
    
    public func fetchOlderMessages(numberOfMessages: UInt, completionHandler: CompletionHandler? = nil) {
        guard self.pagedState == .partiallyPopulated, let lastMessageIdentifier = self.message(at: 0)?.identifier else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.pagedState = .fetching
        
        self.messageFactory.receiveOldMessages(numberOfMessages: Int(numberOfMessages), lastMessageIdentifier: lastMessageIdentifier, delay: 1.0) {
            self.pagedState = .partiallyPopulated
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData() {
        guard self.realTimeState == .initializing else {
            return
        }
        
        self.realTimeState = .online
        
        self.messageFactory.receiveInitialMessages(numberOfMessages: 10, delay: 1.0) {
            self.pagedState = .partiallyPopulated
        }
    }
    
}

// MARK: - FetchedResultsControllerDelegate

extension RoomDetailsProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        self.delegate?.roomDetailsProvider(self, didReceiveMessagesAtIndexRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let message = try? object.snapshot() else {
            return
        }
        
        self.delegate?.roomDetailsProvider(self, didChangeMessageAtIndex: index, previousValue: message)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let message = try? object.snapshot() else {
            return
        }
        
        self.delegate?.roomDetailsProvider(self, didDeleteMessageAtIndex: index, previousValue: message)
    }
    
}

// MARK: - Delegate

public protocol RoomDetailsProviderDelegate: class {
    
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didReceiveMessagesAtIndexRange range: Range<Int>)
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didChangeMessageAtIndex index: Int, previousValue: Message)
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didDeleteMessageAtIndex index: Int, previousValue: Message)
    
}
