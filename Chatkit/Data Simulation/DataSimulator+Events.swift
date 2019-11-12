import Foundation
import CoreData

extension DataSimulator {
    
    // MARK: - Internal methods
    
    func loadInitialState(completionHandler: @escaping (User) -> Void) {
        let persistenceController = self.persistenceController
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            persistenceController.performBackgroundTask { context in
                let currentUser = self.createUser(in: context, identifier: "olivia", name: "Olivia")
                self.currentUserID = currentUser.objectID
                
                let firstUser = self.createUser(in: context, identifier: "oliver", name: "Oliver")
                self.firstUserID = firstUser.objectID
                
                let secondUser = self.createUser(in: context, identifier: "harry", name: "Harry")
                self.secondUserID = secondUser.objectID
                
                let thirdUser = self.createUser(in: context, identifier: "george", name: "George")
                self.thirdUserID = thirdUser.objectID
                
                let fourthUser = self.createUser(in: context, identifier: "noah", name: "Noah")
                self.fourthUserID = fourthUser.objectID
                
                let fifthUser = self.createUser(in: context, identifier: "jack", name: "Jack")
                self.fifthUserID = fifthUser.objectID
                
                let sixthUser = self.createUser(in: context, identifier: "jacob", name: "Jacob")
                self.sixthUserID = sixthUser.objectID
                
                let seventhUser = self.createUser(in: context, identifier: "bob", name: "Bob")
                self.seventhUserID = seventhUser.objectID
                
                let eighthUser = self.createUser(in: context, identifier: "leo", name: "Leo")
                self.eighthUserID = eighthUser.objectID
                
                let ninthUser = self.createUser(in: context, identifier: "oscar", name: "Oscar")
                self.ninthUserID = ninthUser.objectID
                
                let tenthUser = self.createUser(in: context, identifier: "charlie", name: "Charlie")
                self.tenthUserID = tenthUser.objectID
                
                let firstRoom = self.createRoom(in: context, identifier: "firstRoom", name: "Oliver's room", members: [currentUser, firstUser])
                self.firstRoomID = firstRoom.objectID
                
                let secondRoom = self.createRoom(in: context, identifier: "secondRoom", name: "Harry's room", members: [currentUser, secondUser])
                self.secondRoomID = secondRoom.objectID
                
                let thirdRoom = self.createRoom(in: context, identifier: "thirdRoom", name: "George's room", members: [currentUser, thirdUser])
                self.thirdRoomID = thirdRoom.objectID
                
                let fourthRoom = self.createRoom(in: context, identifier: "fourthRoom", name: "Noah's room", members: [currentUser, fourthUser])
                self.fourthRoomID = fourthRoom.objectID
                
                let fifthRoom = self.createRoom(in: context, identifier: "fifthRoom", name: "Jack's room", members: [currentUser, fifthUser])
                self.fifthRoomID = fifthRoom.objectID
                
                let sixthRoom = self.createRoom(in: context, identifier: "sixthRoom", name: "Jacob's room", members: [currentUser, sixthUser])
                self.sixthRoomID = sixthRoom.objectID
                
                let seventhRoom = self.createRoom(in: context, identifier: "seventhRoom", name: "Bob's room", members: [currentUser, seventhUser])
                self.seventhRoomID = seventhRoom.objectID
                
                let eighthRoom = self.createRoom(in: context, identifier: "eighthRoom", name: "Leo's room", members: [currentUser, eighthUser])
                self.eighthRoomID = eighthRoom.objectID
                
                let ninthRoom = self.createRoom(in: context, identifier: "ninthRoom", name: "Oscar's room", members: [currentUser, ninthUser])
                self.ninthRoomID = ninthRoom.objectID
                
                let tenthRoom = self.createRoom(in: context, identifier: "tenthRoom", name: "Charlie's room", members: [currentUser, tenthUser])
                self.tenthRoomID = tenthRoom.objectID
                
                self.createMessage(in: context, content: "Hello", sender: firstUser, room: firstRoom)
                self.createMessage(in: context, content: "Hello", sender: secondUser, room: secondRoom)
                self.createMessage(in: context, content: "Hello", sender: thirdUser, room: thirdRoom)
                self.createMessage(in: context, content: "Hello", sender: fourthUser, room: fourthRoom)
                self.createMessage(in: context, content: "Hello", sender: fifthUser, room: fifthRoom)
                self.createMessage(in: context, content: "Hello", sender: sixthUser, room: sixthRoom)
                self.createMessage(in: context, content: "Hello", sender: seventhUser, room: seventhRoom)
                self.createMessage(in: context, content: "Hello", sender: eighthUser, room: eighthRoom)
                self.createMessage(in: context, content: "Hello", sender: ninthUser, room: ninthRoom)
                self.createMessage(in: context, content: "Hello", sender: tenthUser, room: tenthRoom)
                
                try? context.save()
                
                self.persistenceController.save()
                
                guard let snapshot = try? currentUser.snapshot() else {
                    fatalError("Failed to create current user.")
                }
                
                DispatchQueue.main.async {
                    completionHandler(snapshot)
                }
            }
        }
    }
    
    func scheduleAllEvents() {
        self.schedule(self.createHowCanIHelpMessageFromOlivia(), after: 4.0)
        self.schedule(self.createIAmNotSureMessageFromGeorge(), after: 6.0)
        self.schedule(self.createNewRoomForAmelia(), after: 10.0)
    }
    
    // MARK: - Private methods
    
    private func createUser(in context: NSManagedObjectContext, identifier: String, name: String) -> UserEntity {
        let now = Date()
        
        let user = context.create(UserEntity.self)
        user.identifier = identifier
        user.name = name
        user.createdAt = now
        user.updatedAt = now
        
        return user
    }
    
    private func createRoom(in context: NSManagedObjectContext, identifier: String, name: String, members: [UserEntity]) -> RoomEntity {
        let now = Date()
        
        let room = context.create(RoomEntity.self)
        room.identifier = identifier
        room.name = name
        room.unreadCount = 0
        room.isPrivate = false
        room.createdAt = now
        room.updatedAt = now
        
        for member in members {
            room.addToMembers(member)
        }
        
        return room
    }
    
    @discardableResult private func createMessage(in context: NSManagedObjectContext, identifier: String? = nil, content: String, sender: UserEntity, room: RoomEntity) -> MessageEntity {
        let now = Date()
        
        let part = context.create(InlinePartEntity.self)
        part.content = content
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier ?? self.calculateMessageIdentifier()
        message.sender = sender
        message.createdAt = now
        message.updatedAt = now
        message.addToParts(part)
        
        room.addToMessages(message)
        
        return message
    }
    
    private func createNewRoomForAmelia() -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let currentUserID = self.currentUserID,
                    let currentUser = context.object(with: currentUserID) as? UserEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                let eleventhUser = self.createUser(in: context, identifier: "amelia", name: "Amelia")
                self.eleventhUserID = eleventhUser.objectID
                
                let eleventhRoom = self.createRoom(in: context, identifier: "eleventhRoom", name: "Amelia's room", members: [currentUser, eleventhUser])
                self.eleventhRoomID = eleventhRoom.objectID
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
    private func createHowCanIHelpMessageFromOlivia() -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let currentUserID = self.currentUserID,
                let currentUser = context.object(with: currentUserID) as? UserEntity,
                    let thirdRoomID = self.thirdRoomID,
                    let thirdRoom = context.object(with: thirdRoomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                self.createMessage(in: context, content: "How can I help?", sender: currentUser, room: thirdRoom)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
    private func createIAmNotSureMessageFromGeorge() -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let thirdUserID = self.thirdUserID,
                    let thirdUser = context.object(with: thirdUserID) as? UserEntity,
                    let thirdRoomID = self.thirdRoomID,
                    let thirdRoom = context.object(with: thirdRoomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                self.createMessage(in: context, content: "I am not sure :|", sender: thirdUser, room: thirdRoom)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
}
