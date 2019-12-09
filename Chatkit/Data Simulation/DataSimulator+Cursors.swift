import Foundation

extension DataSimulator {
    
    // MARK: - Internal methods
    
    func markMessagesAsRead(lastReadMessage: Message) {
        let persistenceController = self.persistenceController
        
        persistenceController.performBackgroundTask { context in
            guard let message = context.object(with: lastReadMessage.objectID) as? MessageEntity else {
                return
            }
            
            let room = message.room
            
            guard let messages = room.messages?.array as? [MessageEntity],
                let index = messages.index(of: message) else {
                    return
            }
            
            let numberOfUnreadMessages = messages.dropFirst(index + 1).count
            
            if numberOfUnreadMessages < room.unreadCount {
                room.unreadCount = Int64(numberOfUnreadMessages)
            }
            
            self.persistenceController.save(includingBackgroundTaskContext: context)
        }
    }
    
}
