import Foundation
import CoreData
import PusherPlatform

public class MessageProvider: NSObject, DataProvider {
    
    // MARK: - Properties
    
    public private(set) var isFetchingOlderMessages: Bool
    public let logger: PPLogger?
    
    public weak var delegate: MessageProviderDelegate?
    
    private let persistenceController: PersistenceController
    private let chatkitClient: ChatkitClient
    private let roomIdentifier: NSManagedObjectID
    private var messages: [MessageEntity]
    
    // MARK: - Accessors
    
    public var numberOfAvailableMessages: Int {
        return self.messages.count
    }
    
    // MARK: - Initializers
    
    init(
        room: Room,
        persistenceController: PersistenceController,
        chatkitClient: ChatkitClient,
        logger: PPLogger? = nil
    ) {
        self.persistenceController = persistenceController
        self.chatkitClient = chatkitClient
        self.roomIdentifier = room.objectID
        self.isFetchingOlderMessages = false
        self.logger = logger
        self.messages = []
        
        super.init()
        
        self.registerForNotifications()
        self.reloadData()
    }
    
    // MARK: - Public methods
    
    public func message(at index: Int) -> Message? {
        // UInt would allow us to remove the first comparison, but it would force developers to cast Int to UInt.
        guard index >= 0, index < self.messages.count else {
            return nil
        }
        
        return (try? self.messages[index].snapshot()) ?? nil
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
        
        self.chatkitClient.fetchMessages(
            room: "TODO",
            from: self.message(at: 0)?.identifier,
            order: "older",
            amount: numberOfMessages
        ) { _ in
            self.isFetchingOlderMessages = false
        }
    }

    // MARK: - Private methods
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: self.persistenceController.mainContext)
    }
    
    private func reloadData() {
        let fetchRequest = NSFetchRequest<MessageEntity>(entityName: String(describing: MessageEntity.self))
        fetchRequest.predicate = NSPredicate(format: "%K == #@", #keyPath(MessageEntity.room), self.roomIdentifier)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: true)]
        fetchRequest.fetchBatchSize = 30
        
        do {
            self.messages = try self.persistenceController.mainContext.fetch(fetchRequest)
        } catch {
            self.logger?.log("Failed to reload messages with error: \(error.localizedDescription)", logLevel: .warning)
        }
    }
    
    private func filterInsertions(_ objects: Set<NSManagedObject>) {
        let messages = objects.compactMap { $0 as? MessageEntity }
        
        guard messages.count > 0 else {
            return
        }
        
        // TODO: Insertion position?
        
        // TODO: Notification
    }
    
    private func filterUpdates(_ objects: Set<NSManagedObject>) {
        let messages = objects.compactMap { $0 as? MessageEntity }
        
        for message in messages {
            // TODO: Notification
        }
    }
    
    private func filterDeletions(_ objects: Set<NSManagedObject>) {
    }
    
    // MARK: - Notifications
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let insertedObjects = (userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>), insertedObjects.count > 0 {
            self.filterInsertions(insertedObjects)
        }
        
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updatedObjects.count > 0 {
            self.filterUpdates(updatedObjects)
        }
        
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletedObjects.count > 0 {
            self.filterDeletions(deletedObjects)
        }
    }
    
    // MARK: - Memory management
    
    deinit {
        // TODO: Unsubscribe
    }
    
}

// MARK: - Delegate

public protocol MessageProviderDelegate: class {
    
    func messageProvider(_ messageProvider: MessageProvider, didReceiveMessagesWithRange range: Range<Int>)
    func messageProvider(_ messageProvider: MessageProvider, didChangeMessageAtIndex index: Int, previousValue: Message)
    func messageProvider(_ messageProvider: MessageProvider, didDeleteMessageAtIndex index: Int, previousValue: Message)
    
}
