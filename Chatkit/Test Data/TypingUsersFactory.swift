import Foundation
import CoreData
import PusherPlatform

class TypingUsersFactory {
    
    private let roomID: NSManagedObjectID
    private let persistenceController: PersistenceController
    private var timer: Timer?
    
    init(roomID: NSManagedObjectID, persistenceController: PersistenceController) {
        self.roomID = roomID
        self.persistenceController = persistenceController
        self.timer = nil
    }
    
    func startTyping() {
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addTypingUser(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTyping() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @discardableResult private func createUser(in context: NSManagedObjectContext, identifier: String) -> UserEntity {
        let now = Date()
        
        let user = context.create(UserEntity.self)
        user.identifier = identifier
        user.name = "User \(identifier)"
        user.createdAt = now
        user.updatedAt = now
        
        return user
    }
    
    private func deleteTypingUser(userID: NSManagedObjectID) {
        self.persistenceController.performBackgroundTask { context in
            guard let user = context.object(with: userID) as? UserEntity,
                let room = context.object(with: self.roomID) as? RoomEntity else {
                    return
            }
            
            user.removeFromTypingInRooms(room)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
        }
    }
    
    @objc private func addTypingUser(_ sender: Timer) {
        self.persistenceController.performBackgroundTask { context in
            guard let room = context.object(with: self.roomID) as? RoomEntity,
                var members = room.members?.set as? Set<UserEntity> else {
                    return
            }
            
            if let typingMembers = room.typingMembers?.set as? Set<UserEntity> {
                members.subtract(typingMembers)
            }
            
            guard let randomMember = members.randomElement() else {
                return
            }
            
            room.addToTypingMembers(randomMember)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
            
            let delay = TimeInterval.random(in: 1..<6)
            let userID = randomMember.objectID
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.deleteTypingUser(userID: userID)
            }
        }
    }
    
}
