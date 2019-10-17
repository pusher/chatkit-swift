import Foundation
import CoreData
import PusherPlatform

class UserEntityFactory {
    
    private let roomID: NSManagedObjectID
    private let persistenceController: PersistenceController
    private var addMemberTimer: Timer?
    private var removeMemberTimer: Timer?
    
    private static let currentUserIdentifier = "0"
    
    static func createCurrentUser(in context: NSManagedObjectContext) -> UserEntity {
        let now = Date()
        
        let user = context.create(UserEntity.self)
        user.identifier = UserEntityFactory.currentUserIdentifier
        user.name = "Current user"
        user.avatar = "http://www.gravatar.com/avatar/grzesiekko?d=identicon"
        user.createdAt = now
        user.updatedAt = now
        
        return user
    }
    
    static let currentUserID: NSManagedObjectID = {
        let persistenceController = TestDataFactory.persistenceController
        
        var userID: NSManagedObjectID? = nil
        let now = Date()
        
        persistenceController.mainContext.performAndWait {
            let user = persistenceController.mainContext.create(UserEntity.self)
            user.identifier = UserEntityFactory.currentUserIdentifier
            user.name = "Current user"
            user.avatar = "http://www.gravatar.com/avatar/grzesiekko?d=identicon"
            user.createdAt = now
            user.updatedAt = now
            
            persistenceController.save()
            
            userID = user.objectID
        }
        
        return userID!
    }()
    
    init(roomID: NSManagedObjectID, persistenceController: PersistenceController) {
        self.roomID = roomID
        self.persistenceController = persistenceController
        self.addMemberTimer = nil
        self.removeMemberTimer = nil
    }
    
    func startAddingNewMembers() {
        guard self.addMemberTimer == nil else {
            return
        }
        
        self.addMemberTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(addNewMember(_:)), userInfo: nil, repeats: true)
    }
    
    func stopAddingNewMembers() {
        self.addMemberTimer?.invalidate()
        self.addMemberTimer = nil
    }
    
    func startRemovingMembers() {
        guard self.removeMemberTimer == nil else {
            return
        }
        
        self.removeMemberTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(removeMember(_:)), userInfo: nil, repeats: true)
    }
    
    func stopRemovingMembers() {
        self.removeMemberTimer?.invalidate()
        self.removeMemberTimer = nil
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
    
    @objc private func addNewMember(_ sender: Timer) {
        self.persistenceController.performBackgroundTask { context in
            let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: false) { (lhs, rhs) -> ComparisonResult in
                guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                    return .orderedSame
                }
                
                return NSNumber(value: lhs).compare(NSNumber(value: rhs))
            }
            
            let lastUserIdentifier = context.fetch(UserEntity.self, sortedBy: [sortDescriptor])?.identifier ?? "-1"
            
            guard let identifier = Int(lastUserIdentifier),
                let room = context.object(with: self.roomID) as? RoomEntity else {
                    return
            }
            
            let user = self.createUser(in: context, identifier: "\(identifier + 1)")
            room.addToMembers(user)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
        }
    }
    
    @objc private func removeMember(_ sender: Timer) {
        self.persistenceController.performBackgroundTask { context in
            let roomPredicate = NSPredicate(format: "ANY %K == %@", #keyPath(UserEntity.room), self.roomID)
            let currentUserPredicate = NSPredicate(format: "%K != %@", #keyPath(UserEntity.identifier), UserEntityFactory.currentUserIdentifier)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [roomPredicate, currentUserPredicate])
            
            guard let user = context.fetch(UserEntity.self, filteredBy: compoundPredicate) else {
                return
            }
            
            context.delete(user)
            
            do {
                try context.save()
            } catch {
                print("Failed to save context with error: \(error.localizedDescription)")
            }
            
            self.persistenceController.save()
        }
    }
    
}
