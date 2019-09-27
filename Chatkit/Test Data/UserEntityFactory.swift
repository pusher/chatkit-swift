import Foundation
import CoreData
import PusherPlatform

class UserEntityFactory {
    
    static let currentUserID: NSManagedObjectID = {
        let persistenceController = TestDataFactory.persistenceController
        
        var userID: NSManagedObjectID? = nil
        let now = Date()
        
        persistenceController.mainContext.performAndWait {
            let user = persistenceController.mainContext.create(UserEntity.self)
            user.identifier = "currentUserIdentifier"
            user.name = "Current user"
            user.avatar = "http://www.gravatar.com/avatar/grzesiekko?d=identicon"
            user.createdAt = now
            user.updatedAt = now
            
            persistenceController.save()
            
            userID = user.objectID
        }
        
        return userID!
    }()
    
}
