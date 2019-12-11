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
                
                self.data.forEach { roomDef in
                    let otherUser = self.createUser(in: context, identifier: roomDef.otherUser.identifier, name: roomDef.otherUser.name)
                    let room = self.createRoom(in: context, identifier: roomDef.otherUser.identifier, planName: roomDef.planName, members: [currentUser, otherUser])
                    var historicMessages = [ServersideMessage]()
                    
                    roomDef.messages.forEach { messageDef in
                        switch messageDef {
                        case .initial(let days, let seconds, let sentByCurrentUser, let content):
                            self.createMessage(in: context,
                                               content: content,
                                               sender: sentByCurrentUser ? currentUser : otherUser,
                                               room: room,
                                               date: Date(timeIntervalSinceNow: -(days * 24 * 60 * 60 + seconds)))
                            
                        case .scheduled(let after, let sentByCurrentUser, let content):
                            self.schedule(self.createTypingIndicatorEvent(for: sentByCurrentUser ? currentUser.objectID : otherUser.objectID,
                                                                          in: room.objectID),
                                          after: after - 1.5)
                            self.schedule(self.createMessageEvent(message: content,
                                                                  from: sentByCurrentUser ? currentUser.objectID : otherUser.objectID,
                                                                  in: room.objectID),
                                          after: after)
                        
                        case .serverside(let days, let seconds, let sentByCurrentUser, let content):
                            historicMessages.append(ServersideMessage(identifier: self.calculateMessageIdentifier(isHistoric: true),
                                                                      content: content,
                                                                      senderID: sentByCurrentUser ? currentUser.objectID : otherUser.objectID,
                                                                      days: days,
                                                                      seconds: seconds))
                        }
                    }
                    
                    self.persistenceController.save(includingBackgroundTaskContext: context)
                    
                    // Now the entities are saved, we can look up the new ID of the Room to store the historic messages against
                    let context = persistenceController.mainContext
                    let persistedRoom = context.object(with: room.objectID)
                    self.serversideMessages[persistedRoom.objectID] = historicMessages
                }
                
                guard let snapshot = try? currentUser.snapshot() else {
                    fatalError("Failed to create current user.")
                }
                
                DispatchQueue.main.async {
                    completionHandler(snapshot)
                }
            }
        }
    }
    
    @discardableResult func createMessage(in context: NSManagedObjectContext, identifier: String? = nil, isHistoric: Bool = false, content: String, sender: UserEntity, room: RoomEntity, date: Date = Date()) -> MessageEntity {
        let part = context.create(InlinePartEntity.self)
        part.content = content
        part.type = "text/plain"
        
        let message = context.create(MessageEntity.self)
        message.identifier = identifier ?? self.calculateMessageIdentifier(isHistoric: isHistoric)
        message.sender = sender
        message.createdAt = date
        message.updatedAt = date
        message.addToParts(part)
        
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
    
    private func createRoom(in context: NSManagedObjectContext, identifier: String, planName: String, members: [UserEntity]) -> RoomEntity {
        let now = Date()
        
        let room = context.create(RoomEntity.self)
        room.identifier = identifier
        room.unreadCount = 0
        room.isPrivate = false
        room.createdAt = now
        room.updatedAt = now
        
        let customData = ["planName" : planName]
        room.name = "\(planName) Plan"
        room.customData = CustomDataSerializer.serialize(customData: customData)
        
        for member in members {
            room.addToMembers(member)
        }
        
        return room
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
                
                persistenceController.save(includingBackgroundTaskContext: context)
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
                
                persistenceController.save(includingBackgroundTaskContext: context)
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
                
                persistenceController.save(includingBackgroundTaskContext: context)
            }
        }
    }
    
}
