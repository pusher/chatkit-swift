import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of messages for a given room.
///
/// Initialy the N most recent messages are available. New messages are automatically added in real time.
/// More older messages can be added on request.
public class MessagesProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of messages.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the provider related to the real time web service.
    ///     - paged: The current state of the provider related to the non-real time web service.
    public private(set) var state: (realTime: RealTimeProviderState, paged: PagedProviderState)
    
    /// The object that is notified when the content of the maintained collection of messages changed.
    public weak var delegate: MessagesProviderDelegate? {
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
    let messageFactory: MessageEntityFactory
    
    /// The array of messages for the given room.
    ///
    /// This array contains all messages for the given room and retrieved from the web service as a result
    /// of either an internal real time subscription to the web service or explicit calls triggered
    /// as a result of calling `fetchOlderMessages(numberOfMessages:completionHandler:)`
    /// method.
    public var messages: [Message] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    // A quick and dirty hack that is here to enable user testing. We should get rid of this in the final version.
    private static var controllers = [String : FetchedResultsController<MessageEntity>]()
    
    // MARK: - Initializers
    
    init(room: Room, currentUser: User, persistenceController: PersistenceController, completionHandler: @escaping CompletionHandler) {
        self.roomIdentifier = room.identifier
        self.state.realTime = .degraded
        self.state.paged = .partiallyPopulated
        
        self.roomManagedObjectID = room.objectID
        self.messageFactory = MessageEntityFactory(roomID: self.roomManagedObjectID, currentUserID: currentUser.objectID, persistenceController: persistenceController)
        
        let context = persistenceController.mainContext
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room), self.roomManagedObjectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                return .orderedSame
            }
            
            return NSNumber(value: lhs).compare(NSNumber(value: rhs))
        }
        
        if let fetchedResultsController = MessagesProvider.controllers[room.identifier] {
            self.fetchedResultsController = fetchedResultsController
        }
        else {
            self.fetchedResultsController = FetchedResultsController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
            MessagesProvider.controllers[room.identifier] = self.fetchedResultsController
        }
        
        self.fetchedResultsController.delegate = self
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
    /// Triggers an asynchronous call to the web service that retrieves a batch of historical messages
    /// currently not present in the maintained collection of messages.
    ///
    /// - Parameters:
    ///     - numberOfMessages: The maximum number of messages that should be retrieved from
    ///     the web service.
    ///     - completionHandler:An optional completion handler called when the call to the web
    ///     service finishes with either a successful result or an error.
    public func fetchOlderMessages(numberOfMessages: UInt, completionHandler: CompletionHandler? = nil) {
        guard self.state.paged == .partiallyPopulated, let lastMessage = self.messages.first else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.state.paged = .fetching
        
        self.messageFactory.receiveOldMessages(numberOfMessages: Int(numberOfMessages), lastMessageIdentifier: lastMessage.identifier, lastMessageDate: lastMessage.createdAt, delay: 1.0) {
            self.state.paged = .partiallyPopulated
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        self.state.realTime = .connected
        
        self.messageFactory.receiveInitialMessages(numberOfMessages: 10, delay: 1.0) {
            self.state.paged = .partiallyPopulated
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Memory management
    
    deinit {
        self.messageFactory.stopReceivingNewMessages()
        self.fetchedResultsController.delegate = nil
    }
    
}

// MARK: - FetchedResultsControllerDelegate

extension MessagesProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        if range.lowerBound == 0 {
            let messages = self.fetchedResultsController.objects[range].compactMap { try? $0.snapshot() }
            self.delegate?.messagesProvider(self, didReceiveOlderMessages: messages)
        }
        else {
            for index in range {
                guard index < self.fetchedResultsController.numberOfObjects,
                    let entity = self.fetchedResultsController.object(at: index),
                    let message = try? entity.snapshot() else {
                        continue
                }
                
                self.delegate?.messagesProvider(self, didReceiveNewMessage: message)
            }
        }
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? MessageEntity, let message = try? object.snapshot() else {
            return
        }
        
        // TODO: Generate the old value based on the new value and the changeset.
        
        self.delegate?.messagesProvider(self, didUpdateMessage: message, previousValue: message)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? MessageEntity, let message = try? object.snapshot() else {
            return
        }
        
        self.delegate?.messagesProvider(self, didRemoveMessage: message)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated `MessagesProvider`
/// when the maintainted collection of messages have changed.
public protocol MessagesProviderDelegate: class {
    
    /// Notifies the receiver that new messages have been added to the maintened collection of
    /// messages.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - messages: The array of older messages received from the web service.
    func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveOlderMessages messages: [Message])
    
    /// Notifies the receiver that new messages have been added to the maintened collection of
    /// messages.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - messages: The new message received from the web service.
    func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveNewMessage message: Message)
    
    /// Notifies the receiver that a message from the maintened collection of messages have been
    /// updated.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - message: The updated value of the message.
    ///     - previousValue: The value of the message prior to the update.
    func messagesProvider(_ messagesProvider: MessagesProvider, didUpdateMessage message: Message, previousValue: Message)
    
    /// Notifies the receiver that a message from the maintened collection of messages have been
    /// removed.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - message: The message removed from the maintened collection of messages.
    func messagesProvider(_ messagesProvider: MessagesProvider, didRemoveMessage message: Message)
    
}
