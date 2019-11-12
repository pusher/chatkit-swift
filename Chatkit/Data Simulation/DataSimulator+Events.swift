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
                
                let eleventhUser = self.createUser(in: context, identifier: "amelia", name: "Amelia")
                self.eleventhUserID = eleventhUser.objectID
                
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
                
                let eleventhRoom = self.createRoom(in: context, identifier: "eleventhRoom", name: "Amelia's room", members: [eleventhUser])
                self.eleventhRoomID = eleventhRoom.objectID
                
                self.createMessage(in: context, content: "Hello", sender: firstUser, room: firstRoom)
                self.createMessage(in: context, content: "Hello", sender: secondUser, room: secondRoom)
                self.createMessage(in: context, content: "Hello", sender: thirdUser, room: thirdRoom)
                self.createMessage(in: context, content: "It's me again", sender: thirdUser, room: thirdRoom)
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
        // George - Olivia
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 3.0)
        self.schedule(self.createMessageEvent(message: "Hi", from: self.currentUserID, in: self.thirdRoomID), after: 4.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 5.0)
        self.schedule(self.createMessageEvent(message: "How can I help?", from: self.currentUserID, in: self.thirdRoomID), after: 6.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 9.0)
        self.schedule(self.createMessageEvent(message: "I am not sure 😐", from: self.thirdUserID, in: self.thirdRoomID), after: 11.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 13.0)
        self.schedule(self.createMessageEvent(message: "Perhaps I could send you our offer?", from: self.currentUserID, in: self.thirdRoomID), after: 15.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 16.0)
        self.schedule(self.createMessageEvent(message: "That sounds great!", from: self.thirdUserID, in: self.thirdRoomID), after: 17.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 20.0)
        self.schedule(self.createMessageEvent(message: "Done 👍", from: self.currentUserID, in: self.thirdRoomID), after: 21.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 22.0)
        self.schedule(self.createMessageEvent(message: "Thank you! Bye bye", from: self.thirdUserID, in: self.thirdRoomID), after: 23.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 24.0)
        self.schedule(self.createMessageEvent(message: "Bye", from: self.currentUserID, in: self.thirdRoomID), after: 25.0)
        
        // Amelia - Olivia
        self.schedule(self.createNewRoomForAmelia(), after: 10.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.eleventhUserID, in: self.eleventhRoomID), after: 11.0)
        self.schedule(self.createMessageEvent(message: "Hi", from: self.eleventhUserID, in: self.eleventhRoomID), after: 12.0)
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
                    let currentUser = context.object(with: currentUserID) as? UserEntity,
                    let eleventhRoomID = self.eleventhRoomID,
                    let eleventhRoom = context.object(with: eleventhRoomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                eleventhRoom.addToMembers(currentUser)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
    private func createTypingIndicatorEvent(for userID: NSManagedObjectID?, in roomID: NSManagedObjectID?) -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let userID = userID,
                    let user = context.object(with: userID) as? UserEntity,
                    let roomID = roomID,
                    let room = context.object(with: roomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                room.addToTypingMembers(user)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
    private func removeTypingIndicatorEvent(for userID: NSManagedObjectID?, in roomID: NSManagedObjectID?) -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let userID = userID,
                    let user = context.object(with: userID) as? UserEntity,
                    let roomID = roomID,
                    let room = context.object(with: roomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                room.removeFromTypingMembers(user)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
    private func createMessageEvent(message: String, from userID: NSManagedObjectID?, in roomID: NSManagedObjectID?) -> Event {
        return Event { persistenceController in
            persistenceController.performBackgroundTask { context in
                guard let userID = userID,
                    let user = context.object(with: userID) as? UserEntity,
                    let roomID = roomID,
                    let room = context.object(with: roomID) as? RoomEntity else {
                        fatalError("Failed to retrieve data.")
                }
                
                self.createMessage(in: context, content: message, sender: user, room: room)
                
                room.removeFromTypingMembers(user)
                
                try? context.save()
                
                persistenceController.save()
            }
        }
    }
    
}
