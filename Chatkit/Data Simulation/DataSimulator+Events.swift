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
                
                self.createMessage(in: context, sender: firstUser, room: firstRoom, content: "Hello")
                self.createMessage(in: context, sender: secondUser, room: secondRoom, content: "Hello")

                self.createMessage(in: context, sender: currentUser, room: thirdRoom, date: oldTs(days: 1, seconds: 35), content: "Hi George!")
                self.createMessage(in: context, sender: currentUser, room: thirdRoom, date: oldTs(days: 1, seconds: 30), content: "That is great to hear")
                self.createMessage(in: context, sender: currentUser, room: thirdRoom, date: oldTs(days: 1, seconds: 25), content: "Which plan would you like to pick?")
                self.createMessage(in: context, sender: thirdUser, room: thirdRoom, date: oldTs(days: 1, seconds: 20), content: "The basic one 💪")
                self.createMessage(in: context, sender: currentUser, room: thirdRoom, date: oldTs(days: 1, seconds: 15), content: "I will send a subscription link to your email address")
                self.createMessage(in: context, sender: thirdUser, room: thirdRoom, date: oldTs(days: 1, seconds: 10), content: "Thank you! Bye bye")
                self.createMessage(in: context, sender: currentUser, room: thirdRoom, date: oldTs(days: 1, seconds: 5), content: "Bye")
                self.createMessage(in: context, sender: thirdUser, room: thirdRoom, date: oldTs(seconds: 40), content: "Hi Olivia")
                self.createMessage(in: context, sender: thirdUser, room: thirdRoom, date: oldTs(seconds: 20), content: "I finished my first daily routine")
                self.createMessage(in: context, sender: thirdUser, room: thirdRoom, date: oldTs(seconds: 10), content: "Unfortunately, I feel completely exhausted now 😰")

                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 320), content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 310), content: "Duis tempus ante non nisi feugiat commodo.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 280), content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 270), content: "Praesent mattis ligula id ligula porta efficitur.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 260), content: "Fusce non felis ut quam egestas accumsan.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 230), content: "Nam ornare volutpat sem non auctor.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 210), content: "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus ac elementum enim.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 120), content: "Proin finibus leo vel turpis consectetur lobortis.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 110), content: "Nullam quis consectetur leo.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 100), content: "Nulla eleifend semper massa vitae pharetra.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 90), content: "Nulla pulvinar, lectus a ultrices molestie, eros velit porta justo, vel tincidunt velit odio ac eros.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 80), content: "Nunc ac faucibus neque.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 2, seconds: 60), content: "Nam tempus eleifend nibh, ut aliquet risus consectetur eu.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 30), content: "Duis mauris elit, blandit ac nisl vel, dignissim venenatis nulla.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 2, seconds: 20), content: "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 1, seconds: 820), content: "Mauris tincidunt fermentum sapien eu pellentesque.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 1, seconds: 720), content: "Nunc quis rutrum felis, ut interdum ligula.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 1, seconds: 620), content: "Nulla faucibus varius erat vel facilisis.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 1, seconds: 520), content: "Aenean tempus leo in eleifend posuere.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 1, seconds: 420), content: "Aliquam ornare magna diam, a consequat neque sodales sit amet.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 0, seconds: 90), content: "Aliquam a orci in elit dictum semper in ut dui.")
                self.createMessage(in: context, sender: fourthUser, room: fourthRoom, date: oldTs(days: 0, seconds: 50), content: "Vestibulum feugiat consequat lacinia.")
                self.createMessage(in: context, sender: currentUser, room: fourthRoom, date: oldTs(days: 0, seconds: 20), content: "Maecenas dapibus sapien nisl, sed interdum nibh suscipit eu.")

                self.createMessage(in: context, sender: fifthUser, room: fifthRoom, content: "Hello")
                self.createMessage(in: context, sender: sixthUser, room: sixthRoom, content: "Hello")
                self.createMessage(in: context, sender: seventhUser, room: seventhRoom, content: "Hello")
                self.createMessage(in: context, sender: eighthUser, room: eighthRoom, content: "Hello")
                self.createMessage(in: context, sender: ninthUser, room: ninthRoom, content: "Hello")
                self.createMessage(in: context, sender: tenthUser, room: tenthRoom, content: "Hello")
                
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
        self.schedule(self.createMessageEvent(message: "Hi George", from: self.currentUserID, in: self.thirdRoomID), after: 4.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 5.0)
        self.schedule(self.createMessageEvent(message: "Did you manage do complete the whole routine?", from: self.currentUserID, in: self.thirdRoomID), after: 6.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 9.0)
        self.schedule(self.createMessageEvent(message: "Yes, I did 😎", from: self.thirdUserID, in: self.thirdRoomID), after: 11.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 13.0)
        self.schedule(self.createMessageEvent(message: "Where there any elements of the routine that were especially hard for you?", from: self.currentUserID, in: self.thirdRoomID), after: 15.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 16.0)
        self.schedule(self.createMessageEvent(message: "I struggled with push-ups 😐", from: self.thirdUserID, in: self.thirdRoomID), after: 17.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 20.0)
        self.schedule(self.createMessageEvent(message: "Perhaps we could reduce the number of push-ups for you and see if that helps tomorrow?", from: self.currentUserID, in: self.thirdRoomID), after: 21.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 22.0)
        self.schedule(self.createMessageEvent(message: "That sound great! 👍", from: self.thirdUserID, in: self.thirdRoomID), after: 23.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 24.0)
        self.schedule(self.createMessageEvent(message: "I will amend your daily routine to include that change", from: self.currentUserID, in: self.thirdRoomID), after: 25.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.thirdUserID, in: self.thirdRoomID), after: 26.0)
        self.schedule(self.createMessageEvent(message: "Thank you! Bye bye", from: self.thirdUserID, in: self.thirdRoomID), after: 27.0)
        
        self.schedule(self.createTypingIndicatorEvent(for: self.currentUserID, in: self.thirdRoomID), after: 28.0)
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
            let customData = ["planID" : "exercise-basic",
                            "planName" : planName]
            
            room.name = "\(planName) Plan"
            room.customData = CustomDataSerializer.serialize(customData: customData)
        }
        else {
            let planName = "Nutrition"
            let customData = ["planID" : "routine-basic",
                            "planName" : planName]
            
            room.name = "\(planName) Plan"
            room.customData = CustomDataSerializer.serialize(customData: customData)
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

private func oldTs(days: Double = 0, seconds: Double = 0) -> Date {
    return Date(timeIntervalSinceNow: -(days * 24 * 60 * 60 + seconds))
}
