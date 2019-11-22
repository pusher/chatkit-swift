import Foundation
import CoreData

extension DataSimulator {
    
    // MARK: - Internal methods
    
    func populateMessageHistory() {
        guard let thirdRoomID = self.thirdRoomID,
            let currentUserID = self.currentUserID,
            let thirdUserID = self.thirdUserID else {
                return
        }

        let ids = IdGenerator()
        
        let context = self.persistenceController.mainContext
        
        context.performAndWait {
            let thirdRoom = context.object(with: thirdRoomID)
            
            // George - Olivia
            self.messageHistory[thirdRoom.objectID] = [
                HistoricMessage(identifier: ids.new(), content: "Hi!", senderID: thirdUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 50.0),
                HistoricMessage(identifier: ids.new(), content: "Hi George!", senderID: currentUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 45.0),
                HistoricMessage(identifier: ids.new(), content: "How can I help you?", senderID: currentUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 40.0),
                HistoricMessage(identifier: ids.new(), content: "I am interested in your offer 🏋️‍♂️", senderID: thirdUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 35.0),
                HistoricMessage(identifier: ids.new(), content: "Should I send you our brochure?", senderID: currentUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 30.0),
                HistoricMessage(identifier: ids.new(), content: "Yes, please", senderID: thirdUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 25.0),
                HistoricMessage(identifier: ids.new(), content: "Done 👍", senderID: currentUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 20.0),
                HistoricMessage(identifier: ids.new(), content: "Thank you!", senderID: thirdUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 15.0),
                HistoricMessage(identifier: ids.new(), content: "Bye bye", senderID: thirdUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0 + 10.0),
                HistoricMessage(identifier: ids.new(), content: "Bye", senderID: currentUserID, timeInterval: 2.0 * 24.0 * 60.0 * 60.0),
                
                HistoricMessage(identifier: ids.new(), content: "Hello", senderID: thirdUserID, timeInterval: 1.0 * 24.0 * 60.0 * 60.0 + 50.0),
                HistoricMessage(identifier: ids.new(), content: "It's me again", senderID: thirdUserID, timeInterval: 1.0 * 24.0 * 60.0 * 60.0 + 45.0),
                HistoricMessage(identifier: ids.new(), content: "I am interested in subscribing to one of your exercise plans 💰", senderID: thirdUserID, timeInterval: 1.0 * 24.0 * 60.0 * 60.0 + 40.0),
            ]

            guard let fourthRoomID = self.fourthRoomID,
                let fourthUserID = self.fourthUserID else {
                    return
            }
            let fourthRoom = context.object(with: fourthRoomID)
            self.messageHistory[fourthRoom.objectID] = [
                HistoricMessage(identifier: ids.new(), content: "Test", senderID: fourthUserID, days: 3, seconds: 955)
            ]
        }
    }
    
    func pagedState(for roomID: NSManagedObjectID) -> PagedProviderState {
        guard let messageHistory = self.messageHistory[roomID] else {
            return .fullyPopulated
        }
        
        return messageHistory.count > 0 ? .partiallyPopulated : .fullyPopulated
    }
    
    func fetchOlderMessages(for roomID: NSManagedObjectID, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard let messageHistory = self.messageHistory[roomID] else {
                completionHandler()
                return
            }
            
            let numberOfMessages = 10
            
            let messages = messageHistory.suffix(numberOfMessages).reversed()
            self.messageHistory[roomID] = messageHistory.dropLast(numberOfMessages)
            
            self.insertHistoricMessages(Array(messages), in: roomID, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Private methods
    
    private func insertHistoricMessages(_ messages: [HistoricMessage], in roomID: NSManagedObjectID, completionHandler: @escaping () -> Void) {
        self.persistenceController.performBackgroundTask { context in
            for message in messages {
                guard let sender = context.object(with: message.senderID) as? UserEntity,
                    let room = context.object(with: roomID) as? RoomEntity else {
                        continue
                }
                
                self.createMessage(in: context, identifier: message.identifier, content: message.content, sender: sender, room: room, date: message.date)
            }
            
            try? context.save()
            
            self.persistenceController.save()
            
            completionHandler()
        }
    }
    
}

// MARK: - Historic message

extension DataSimulator {
    
    struct HistoricMessage {
        
        let identifier: String
        let content: String
        let senderID: NSManagedObjectID
        let date: Date
        
        init(identifier: String, content: String, senderID: NSManagedObjectID, timeInterval: TimeInterval) {
            self.identifier = identifier
            self.content = content
            self.senderID = senderID
            self.date = Date(timeIntervalSinceNow: -timeInterval)
        }

        init(identifier: String, content: String, senderID: NSManagedObjectID, days: Double, seconds: Double) {
            self.identifier = identifier
            self.content = content
            self.senderID = senderID
            self.date = Date(timeIntervalSinceNow: -(days * 24 * 60 * 60 + seconds))
        }

    }
    
}

extension DataSimulator {
    class IdGenerator {
        private var nextId: Int = 100

        public func new() -> String {
            self.nextId += 1
            return String(self.nextId)
        }
    }
}
