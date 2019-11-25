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
            let seconds = Countdown(start: 1000, step: 5)
            self.messageHistory[fourthRoom.objectID] = [
                HistoricMessage(identifier: ids.new(), content: "Morbi in finibus metus, eu auctor massa.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Nunc finibus commodo nibh, eget rhoncus nulla viverra ut.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Ut sed arcu in libero lobortis cursus.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Pellentesque id nibh sit amet nisi congue hendrerit in et sapien.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Pellentesque aliquam enim ut ornare viverra.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Cras tempor, ex eget mattis gravida, est sem accumsan purus, vel imperdiet mauris ligula a ex.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Pellentesque pretium efficitur blandit.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Sed sit amet vestibulum lectus.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Sed justo libero, placerat a suscipit non, sagittis vel metus.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Proin a elit facilisis, consequat felis ut, dignissim tellus.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Donec tempus volutpat turpis vel ultricies.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Nullam vel est condimentum, sodales libero at, ullamcorper urna.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Proin sed iaculis tellus.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Nunc quis imperdiet lectus, eget ultricies felis.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Vivamus eu tempus orci.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Aenean tempor et tortor ac efficitur.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Morbi facilisis faucibus turpis vel ultrices.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Ut quis accumsan neque.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Donec est nulla, imperdiet at mauris accumsan, vulputate feugiat quam.", senderID: fourthUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Pellentesque aliquam enim ac nulla scelerisque egestas.", senderID: currentUserID, days: 3, seconds: seconds.next()),
                HistoricMessage(identifier: ids.new(), content: "Sed aliquam mollis lorem, eu molestie sem gravida eget.", senderID: fourthUserID, days: 3, seconds: seconds.next())
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

    class Countdown {
        private var nextValue: Int
        private let step: Int

        init(start: Int, step: Int) {
            self.nextValue = start
            self.step = step
        }

        public func next() -> Double {
            self.nextValue -= self.step
            return Double(self.nextValue)
        }
    }
}
