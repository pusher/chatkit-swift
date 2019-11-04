import Foundation
import CoreData
import PusherPlatform

class MessageEntityFactory {
    
    private let roomID: NSManagedObjectID
    private let currentUserID: NSManagedObjectID
    private let persistenceController: PersistenceController
    private var timer: Timer?
    
    init(roomID: NSManagedObjectID, currentUserID: NSManagedObjectID, persistenceController: PersistenceController) {
        self.roomID = roomID
        self.currentUserID = currentUserID
        self.persistenceController = persistenceController
        self.timer = nil
    }
    
    func receiveInitialMessages(numberOfMessages: Int, delay: TimeInterval, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                guard context.count(MessageEntity.self, filteredBy: "%K == %@", #keyPath(MessageEntity.room), self.roomID) == 0 else {
                    completionHandler()
                    return
                }
                
                (0..<numberOfMessages).forEach {
                    self.createMessage(in: context, identifier: "\($0)", userID: self.currentUserID, roomID: self.roomID)
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
    
    func receiveOldMessages(numberOfMessages: Int, lastMessageIdentifier: String, lastMessageDate: Date, delay: TimeInterval, completionHandler: @escaping () -> Void) {
        var dateOffset = DateComponents()
        dateOffset.day = -1
        
        guard let lastMessageIdentifier = Int(lastMessageIdentifier),
            let messageDate = Calendar.current.date(byAdding: dateOffset, to: lastMessageDate) else {
                completionHandler()
                return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                ((lastMessageIdentifier - numberOfMessages)..<lastMessageIdentifier).forEach {
                    self.createMessage(in: context, identifier: "\($0)", userID: self.currentUserID, roomID: self.roomID, date: messageDate)
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
    
    @discardableResult private func createMessage(in context: NSManagedObjectContext, identifier: String, userID: NSManagedObjectID, roomID: NSManagedObjectID, date: Date = Date()) -> MessageEntity {
        let part = context.create(InlinePartEntity.self)
        part.content = "Test message: \(identifier)"
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier
        message.room = context.object(with: roomID) as! RoomEntity
        message.sender = context.object(with: userID) as! UserEntity
        message.createdAt = date
        message.updatedAt = date
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
            
            self.createMessage(in: context, identifier: "\(lastIdentifier + 1)", userID: self.currentUserID, roomID: self.roomID)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
        }
    }
    
}
