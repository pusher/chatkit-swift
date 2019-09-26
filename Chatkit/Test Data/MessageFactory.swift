import Foundation
import CoreData
import PusherPlatform

class MessageFactory {
    
    private let persistenceController: PersistenceController
    
    private var timer: Timer?
    
    private let userID: NSManagedObjectID
    private let roomID: NSManagedObjectID
    
    init(roomID: NSManagedObjectID, persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.timer = nil
        self.userID = MessageFactory.createUser(persistenceController: persistenceController)
        self.roomID = roomID
    }
    
    func receiveInitialMessages(numberOfMessages: Int, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                guard context.count(MessageEntity.self, filteredBy: "%K == %@", #keyPath(MessageEntity.room), self.roomID) == 0 else {
                    return
                }
                
                (0..<numberOfMessages).forEach {
                    self.createMessage(in: context, identifier: "\($0)", userID: self.userID, roomID: self.roomID)
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save context with error: \(error.localizedDescription)")
                }
                
                self.persistenceController.save()
            }
        }
    }
    
    func receiveOldMessages(numberOfMessages: Int, lastMessageIdentifier: String, delay: TimeInterval, completionHandler: @escaping () -> Void) {
        guard let lastMessageIdentifier = Int(lastMessageIdentifier) else {
            completionHandler()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                ((lastMessageIdentifier - numberOfMessages)..<lastMessageIdentifier).forEach {
                    self.createMessage(in: context, identifier: "\($0)", userID: self.userID, roomID: self.roomID)
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save context with error: \(error.localizedDescription)")
                }
                
                self.persistenceController.save()
                
                completionHandler()
            }
        }
    }
    
    func startReceivingNewMessages() {
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(receiveNewMessage(_:)), userInfo: nil, repeats: true)
    }
    
    func stopReceivingNewMessages() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private static func createUser(persistenceController: PersistenceController) -> NSManagedObjectID {
        var user: UserEntity? = nil
        let now = Date()
        
        persistenceController.mainContext.performAndWait {
            user = persistenceController.mainContext.create(UserEntity.self)
            user?.identifier = "testUserIdentifier"
            user?.name = "User: testUserIdentifier"
            user?.avatar = "http://www.gravatar.com/avatar/grzesiekko?d=identicon"
            user?.createdAt = now
            user?.updatedAt = now
            
            persistenceController.save()
        }
        
        return user!.objectID
    }
    
    @discardableResult private func createMessage(in context: NSManagedObjectContext, identifier: String, userID: NSManagedObjectID, roomID: NSManagedObjectID) -> MessageEntity {
        let now = Date()
        
        let part = context.create(InlinePartEntity.self)
        part.content = "Test message: \(identifier)"
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier
        message.room = context.object(with: roomID) as! RoomEntity
        message.sender = context.object(with: userID) as! UserEntity
        message.createdAt = now
        message.updatedAt = now
        message.addToParts(part)
        
        return message
    }
    
    @objc private func receiveNewMessage(_ sender: Timer) {
        self.persistenceController.performBackgroundTask { context in
            let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: false) { (lhs, rhs) -> ComparisonResult in
                guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                    return .orderedSame
                }
                
                return NSNumber(value: lhs).compare(NSNumber(value: rhs))
            }
            
            guard let lastMessage = context.fetch(MessageEntity.self, sortedBy: [sortDescriptor], filteredBy: "%K == %@", #keyPath(MessageEntity.room), self.roomID),
                let lastIdentifier = Int(lastMessage.identifier) else {
                    return
            }
            
            self.createMessage(in: context, identifier: "\(lastIdentifier + 1)", userID: self.userID, roomID: self.roomID)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
        }
    }
    
}
