import Foundation
import CoreData

extension DataSimulator {

    // MARK: - Internal methods

    func pagedState(for roomID: NSManagedObjectID) -> PagedProviderState {
        guard let messageHistory = self.serversideMessages[roomID] else {
            return .fullyPopulated
        }
        
        return messageHistory.count > 0 ? .partiallyPopulated : .fullyPopulated
    }
    
    func fetchOlderMessages(for roomID: NSManagedObjectID, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard let messageHistory = self.serversideMessages[roomID] else {
                completionHandler()
                return
            }
            
            let numberOfMessages = 10
            
            let messages = messageHistory.suffix(numberOfMessages)
            self.serversideMessages[roomID] = messageHistory.dropLast(numberOfMessages)
            
            self.insertHistoricMessages(Array(messages), in: roomID, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Private methods
    
    private func insertHistoricMessages(_ messages: [ServersideMessage], in roomID: NSManagedObjectID, completionHandler: @escaping () -> Void) {
        self.persistenceController.performBackgroundTask { context in
            for message in messages {
                guard let sender = context.object(with: message.senderID) as? UserEntity,
                    let room = context.object(with: roomID) as? RoomEntity else {
                        continue
                }
                
                self.createMessage(in: context, identifier: message.identifier, isHistoric: true, content: message.content, sender: sender, room: room, date: message.date)
            }
            
            self.persistenceController.save(includingBackgroundTaskContext: context)
            
            completionHandler()
        }
    }
    
}

// MARK: - Historic message

extension DataSimulator {
    
    struct ServersideMessage {
        let identifier: String
        let content: String
        let senderID: NSManagedObjectID
        let date: Date
        
        init(identifier: String, content: String, senderID: NSManagedObjectID, days: Double, seconds: Double) {
            self.identifier = identifier
            self.content = content
            self.senderID = senderID
            self.date = Date(timeIntervalSinceNow: -(days * 24 * 60 * 60 + seconds))
        }
    }

    struct DummyRoom {
        let planName: String
        let otherUser: DummyUser
        let messages: [DummyMessage]
    }

    struct DummyUser {
        let identifier: String
        let name: String
    }

    enum DummyMessage {
        case serverside(days: Double = 0.0, seconds: Double, sentByCurrentUser: Bool, content: String)
        case initial(days: Double = 0.0, seconds: Double, sentByCurrentUser: Bool, content: String)
        case scheduled(after: Double, sentByCurrentUser: Bool, content: String)
    }
}
