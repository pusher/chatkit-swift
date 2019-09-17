import Foundation
import CoreData
import PusherPlatform

public class MessageProvider: NSObject, DataProvider {
    
    // MARK: - Properties
    
    public private(set) var isFetchingOlderMessages: Bool
    
    public weak var delegate: MessageProviderDelegate?
    
    private let roomIdentifier: String
    
    private var messages: [Message]
    private var timer: Timer?
    
    // MARK: - Accessors
    
//    public var count: Int {
//    public var numberOfMessages: Int {
//    public var numberOfFetchedMessages: Int {
//    public var numberOfReceivedMessages: Int {
    public var numberOfAvailableMessages: Int {
        return self.messages.count
    }
    
    // MARK: - Initializers
    
//    public init(room: Room) {
//        self.roomIdentifier = room.identifier
    public init(roomIdentifier: String) {
        self.roomIdentifier = roomIdentifier
        self.isFetchingOlderMessages = false
        
        self.messages = Factory.createMessages(amount: 10)
        self.timer = nil
        
        super.init()
        
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(createNewMessage(_:)), userInfo: nil, repeats: true)
    }
    
    // MARK: - Public methods
    
    public func message(at index: Int) -> Message? {
        // UInt would allow us to remove the first comparison, but it would force developers to cast Int to UInt.
        guard index >= 0, index < self.messages.count else {
            return nil
        }
        
        return self.messages[index]
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isFetchingOlderMessages = false
            
            let receivedMessages = Factory.createMessages(amount: numberOfMessages)
            self.messages.insert(contentsOf: receivedMessages, at: 0)
            
            self.delegate?.messageProvider(self, didReceiveMessagesWithRange: 0..<Int(numberOfMessages))
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Timers
    
    @objc private func createNewMessage(_ sender: Timer) {
        let message = Factory.createMessage()
        self.messages.append(message)
        
        let range = Range<Int>(uncheckedBounds: (lower: self.messages.count - 1, upper: self.messages.count))
        
        self.delegate?.messageProvider(self, didReceiveMessagesWithRange: range)
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

// MARK: - Factory

private extension MessageProvider {
    
    class Factory {
        
        // MARK: - Properties
        
        private static let persistenceController: PersistenceController = {
            let model = NSManagedObjectModel.mergedModel(from: [Bundle.current])!
            
            let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
            storeDescription.shouldAddStoreAsynchronously = false
            
            return try! PersistenceController(model: model, storeDescriptions: [storeDescription])
        }()
        
        // MARK: - Internal methods
        
        class func createUser() -> User {
            let now = Date()
            let number = Int.random(in: 1..<10000)
            let userManagedObjectID = Factory.persistenceController.mainContext.create(UserEntity.self).objectID
            
            return User(identifier: "user\(number)",
                        name: "Greg \(number)",
                        avatar: nil,
                        presenceState: .unknown,
                        metadata: nil,
                        createdAt: now,
                        updatedAt: now,
                        objectID: userManagedObjectID)
        }
        
        class func createMessage() -> Message {
            let now = Date()
            let number = Int.random(in: 1..<10000)
            let messageManagedObjectID = Factory.persistenceController.mainContext.create(MessageEntity.self).objectID
            let part = MessagePart.text("text/plain", "Message number \(number)")
            
            return Message(identifier: "testIdentifier",
                           sender: Factory.createUser(),
                           parts: [part],
                           readByUsers: nil,
                           lastReadByUsers: nil,
                           createdAt: now,
                           updatedAt: now,
                           deletedAt: nil,
                           objectID: messageManagedObjectID
            )
        }
        
        class func createMessages(amount: UInt) -> [Message] {
            return (0..<amount).map { _ in
                Factory.createMessage()
            }
        }
        
    }
    
}
