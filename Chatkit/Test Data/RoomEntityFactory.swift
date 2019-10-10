import Foundation
import CoreData
import PusherPlatform

class RoomEntityFactory {
    
    private let currentUserManagedObjectID: NSManagedObjectID
    private let persistenceController: PersistenceController
    
    init(currentUserManagedObjectID: NSManagedObjectID, persistenceController: PersistenceController) {
        self.currentUserManagedObjectID = currentUserManagedObjectID
        self.persistenceController = persistenceController
    }
    
    func receiveInitialListOfRooms(numberOfRooms: Int, delay: TimeInterval, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                guard let currentUser = context.object(with: self.currentUserManagedObjectID) as? UserEntity else {
                    completionHandler()
                    return
                }
                
                (0..<numberOfRooms).forEach {
                    self.createRoom(in: context, identifier: "\($0)", member: currentUser)
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save context with error: \(error.localizedDescription)")
                }
                
                self.persistenceController.save()
                
                completionHandler()
            }
        }
    }
    
    @discardableResult private func createRoom(in context: NSManagedObjectContext, identifier: String, member: UserEntity? = nil) -> RoomEntity {
        let now = Date()
        
        let room = context.create(RoomEntity.self)
        room.identifier = identifier
        room.name = "Room: \(identifier)"
        room.unreadCount = 3
        room.isPrivate = false
        room.createdAt = now
        room.updatedAt = now
        
        if let member = member {
            room.addToMembers(member)
        }
        
        return room
    }
    
}
