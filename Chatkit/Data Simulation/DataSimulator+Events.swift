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
                
                let firstRoom = self.createRoom(in: context, identifier: "firstRoom", members: [currentUser, firstUser])
                self.firstRoomID = firstRoom.objectID
                
                let secondRoom = self.createRoom(in: context, identifier: "secondRoom", members: [currentUser, secondUser])
                self.secondRoomID = secondRoom.objectID
                
                let thirdRoom = self.createRoom(in: context, identifier: "thirdRoom", isSubscribedToExerciseRoutinesPlan: true, members: [currentUser, thirdUser])
                self.thirdRoomID = thirdRoom.objectID
                
                let fourthRoom = self.createRoom(in: context, identifier: "fourthRoom", members: [currentUser, fourthUser])
                self.fourthRoomID = fourthRoom.objectID
                
                let fifthRoom = self.createRoom(in: context, identifier: "fifthRoom", members: [currentUser, fifthUser])
                self.fifthRoomID = fifthRoom.objectID
                
                let sixthRoom = self.createRoom(in: context, identifier: "sixthRoom", members: [currentUser, sixthUser])
                self.sixthRoomID = sixthRoom.objectID
                
                let seventhRoom = self.createRoom(in: context, identifier: "seventhRoom", members: [currentUser, seventhUser])
                self.seventhRoomID = seventhRoom.objectID
                
                let eighthRoom = self.createRoom(in: context, identifier: "eighthRoom", members: [currentUser, eighthUser])
                self.eighthRoomID = eighthRoom.objectID
                
                let ninthRoom = self.createRoom(in: context, identifier: "ninthRoom", members: [currentUser, ninthUser])
                self.ninthRoomID = ninthRoom.objectID
                
                let tenthRoom = self.createRoom(in: context, identifier: "tenthRoom", members: [currentUser, tenthUser])
                self.tenthRoomID = tenthRoom.objectID
                
                let eleventhRoom = self.createRoom(in: context, identifier: "eleventhRoom", members: [eleventhUser])
                self.eleventhRoomID = eleventhRoom.objectID
                
                self.createMessage(in: context, content: "Hello", sender: firstUser, room: firstRoom)
                self.createMessage(in: context, content: "Hello", sender: secondUser, room: secondRoom)
                self.createMessage(in: context, content: "Hi Olivia", sender: thirdUser, room: thirdRoom)
                self.createMessage(in: context, content: "I finished my first daily routine", sender: thirdUser, room: thirdRoom)
                self.createMessage(in: context, content: "Unfortunately, I feel completely exhausted now 😰", sender: thirdUser, room: thirdRoom)
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
        self.schedule(self.createMessageEvent(message: "Hi George", from: self.currentUserID, in: self.thirdRoomID), after: 4.0)
        
        self.schedule(self.createMessageEvent(message: "Did you manage do complete the whole routine?", from: self.currentUserID, in: self.thirdRoomID), after: 6.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 9.0)
        self.schedule(self.createMessageEvent(message: "Yes, I did 😎", from: self.thirdUserID, in: self.thirdRoomID), after: 11.0)
        
        self.schedule(self.createMessageEvent(message: "Where there any elements of the routine that were especially hard for you?", from: self.currentUserID, in: self.thirdRoomID), after: 15.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 16.0)
        self.schedule(self.createMessageEvent(message: "I struggled with push-ups 😐", from: self.thirdUserID, in: self.thirdRoomID), after: 17.0)
        
        self.schedule(self.createMessageEvent(message: "Perhaps we could reduce the number of push-ups for you and see if that helps tomorrow?", from: self.currentUserID, in: self.thirdRoomID), after: 21.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 22.0)
        self.schedule(self.createMessageEvent(message: "That sound great! 👍", from: self.thirdUserID, in: self.thirdRoomID), after: 23.0)
        
        self.schedule(self.createMessageEvent(message: "I will amend your daily routine to include that change", from: self.currentUserID, in: self.thirdRoomID), after: 25.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 26.0)
        self.schedule(self.createMessageEvent(message: "Thank you! Bye bye", from: self.thirdUserID, in: self.thirdRoomID), after: 27.0)
        
        self.schedule(self.createMessageEvent(message: "Bye", from: self.currentUserID, in: self.thirdRoomID), after: 29.0)
        
        // Amelia - Olivia
        self.schedule(self.createNewRoomForAmelia(), after: 10.0)
        self.schedule(self.createTypingIndicatorEvent(for: self.eleventhUserID, in: self.eleventhRoomID), after: 11.0)
        self.schedule(self.createMessageEvent(message: "Hi", from: self.eleventhUserID, in: self.eleventhRoomID), after: 12.0)
    }
    
    @discardableResult func createMessage(in context: NSManagedObjectContext, identifier: String? = nil, content: String, sender: UserEntity, room: RoomEntity, date: Date = Date()) -> MessageEntity {
        let part = context.create(InlinePartEntity.self)
        part.content = content
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier ?? self.calculateMessageIdentifier()
        message.sender = sender
        message.createdAt = date
        message.updatedAt = date
        message.addToParts(part)
        
        var isHistoric = false
        
        // This is a simplification, but should be enough for the simulation.
        if let firstMessage = room.messages?.firstObject as? MessageEntity,
            let firstMessageIdentifier = Int(firstMessage.identifier),
            let currentMessageIdentifier = Int(message.identifier),
            currentMessageIdentifier < firstMessageIdentifier {
            isHistoric = true
        }
        
        if isHistoric {
            room.insertIntoMessages(message, at: 0)
        }
        else {
            room.addToMessages(message)
            room.unreadCount += 1
        }
        
        return message
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
    
    private func createRoom(in context: NSManagedObjectContext, identifier: String, isSubscribedToExerciseRoutinesPlan: Bool = false, members: [UserEntity]) -> RoomEntity {
        let now = Date()
        
        let room = context.create(RoomEntity.self)
        room.identifier = identifier
        room.unreadCount = 0
        room.isPrivate = false
        room.createdAt = now
        room.updatedAt = now
        
        if isSubscribedToExerciseRoutinesPlan {
            let planName = "Exercise Routine"
            let userData = ["planID" : "exercise-basic",
                            "planName" : planName]
            
            room.name = "\(planName) Plan"
            room.userData = UserDataSerializer.serialize(userData: userData)
        }
        else {
            let planName = "Nutrition"
            let userData = ["planID" : "routine-basic",
                            "planName" : planName]
            
            room.name = "\(planName) Plan"
            room.userData = UserDataSerializer.serialize(userData: userData)
        }
        
        for member in members {
            room.addToMembers(member)
        }
        
        return room
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
