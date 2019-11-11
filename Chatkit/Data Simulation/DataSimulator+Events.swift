import Foundation
import CoreData

extension DataSimulator {
    
    // MARK: - Internal methods
    
    func loadInitialState(completionHandler: @escaping (User) -> Void) {
        let context = self.persistenceController.mainContext
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var snapshot: User? = nil
            
            context.performAndWait {
                let currentUser = self.createUser(in: context, identifier: "olivia", name: "Olivia")
                self.currentUser = currentUser
                
                let firstUser = self.createUser(in: context, identifier: "oliver", name: "Oliver")
                self.firstUser = firstUser
                
                let secondUser = self.createUser(in: context, identifier: "harry", name: "Harry")
                self.secondUser = secondUser
                
                let thirdUser = self.createUser(in: context, identifier: "george", name: "George")
                self.thirdUser = thirdUser
                
                let fourthUser = self.createUser(in: context, identifier: "noah", name: "Noah")
                self.fourthUser = fourthUser
                
                let fifthUser = self.createUser(in: context, identifier: "jack", name: "Jack")
                self.fifthUser = fifthUser
                
                let sixthUser = self.createUser(in: context, identifier: "jacob", name: "Jacob")
                self.sixthUser = sixthUser
                
                let seventhUser = self.createUser(in: context, identifier: "bob", name: "Bob")
                self.seventhUser = seventhUser
                
                let eighthUser = self.createUser(in: context, identifier: "leo", name: "Leo")
                self.eighthUser = eighthUser
                
                let ninthUser = self.createUser(in: context, identifier: "oscar", name: "Oscar")
                self.ninthUser = ninthUser
                
                let tenthUser = self.createUser(in: context, identifier: "charlie", name: "Charlie")
                self.tenthUser = tenthUser
                
                let firstRoom = self.createRoom(in: context, identifier: "firstRoom", name: "Oliver's room", members: [currentUser, firstUser])
                self.firstRoom = firstRoom
                
                let secondRoom = self.createRoom(in: context, identifier: "secondRoom", name: "Harry's room", members: [currentUser, secondUser])
                self.secondRoom = secondRoom
                
                let thirdRoom = self.createRoom(in: context, identifier: "thirdRoom", name: "George's room", members: [currentUser, thirdUser])
                self.thirdRoom = thirdRoom
                
                let fourthRoom = self.createRoom(in: context, identifier: "fourthRoom", name: "Noah's room", members: [currentUser, fourthUser])
                self.fourthRoom = fourthRoom
                
                let fifthRoom = self.createRoom(in: context, identifier: "fifthRoom", name: "Jack's room", members: [currentUser, fifthUser])
                self.fifthRoom = fifthRoom
                
                let sixthRoom = self.createRoom(in: context, identifier: "sixthRoom", name: "Jacob's room", members: [currentUser, sixthUser])
                self.sixthRoom = sixthRoom
                
                let seventhRoom = self.createRoom(in: context, identifier: "seventhRoom", name: "Bob's room", members: [currentUser, seventhUser])
                self.seventhRoom = seventhRoom
                
                let eighthRoom = self.createRoom(in: context, identifier: "eighthRoom", name: "Leo's room", members: [currentUser, eighthUser])
                self.eighthRoom = eighthRoom
                
                let ninthRoom = self.createRoom(in: context, identifier: "ninthRoom", name: "Oscar's room", members: [currentUser, ninthUser])
                self.ninthRoom = ninthRoom
                
                let tenthRoom = self.createRoom(in: context, identifier: "tenthRoom", name: "Charlie's room", members: [currentUser, tenthUser])
                self.tenthRoom = tenthRoom
                
                self.createMessage(in: context, identifier: "1", content: "Hello", sender: tenthUser, room: tenthRoom)
                self.createMessage(in: context, identifier: "2", content: "Hello", sender: currentUser, room: tenthRoom)
                
                self.persistenceController.save()
                
                snapshot = try? currentUser.snapshot()
            }
            
            guard let currentUser = snapshot else {
                fatalError("Failed to create current user.")
            }
            
            completionHandler(currentUser)
        }
    }
    
    func scheduleAllEvents() {
        let newRoomEvent = self.createNewRoomEvent()
        self.schedule(newRoomEvent, after: 5.0)
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
    
    @discardableResult private func createMessage(in context: NSManagedObjectContext, identifier: String, content: String, sender: UserEntity, room: RoomEntity) -> MessageEntity {
        let now = Date()
        
        let part = context.create(InlinePartEntity.self)
        part.content = content
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier
        message.sender = sender
        message.createdAt = now
        message.updatedAt = now
        message.addToParts(part)
        
        room.addToMessages(message)
        
        return message
    }
    
    private func createNewRoomEvent() -> Event {
        return Event { persistenceController in
            guard let currentUser = self.currentUser else {
                return
            }
            
            let context = persistenceController.mainContext
            
            let eleventhUser = self.createUser(in: context, identifier: "amelia", name: "Amelia")
            self.eleventhUser = eleventhUser
            
            let eleventhRoom = self.createRoom(in: context, identifier: "eleventhRoom", name: "Amelia's room", members: [currentUser, eleventhUser])
            self.eleventhRoom = eleventhRoom
            
            persistenceController.save()
        }
    }
    
}
