import Foundation
import CoreData
import PusherPlatform

class RoomFactory {
    
    private let persistenceController: PersistenceController
    
    private var timer: Timer?
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.timer = nil
    }
    
    func receiveInitialListOfRooms(numberOfRooms: Int, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.persistenceController.performBackgroundTask { context in
                (0..<numberOfRooms).forEach {
                    self.createRoom(in: context, identifier: "\($0)")
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save context with error: \(error.localizedDescription)")
                }
                
                self.persistenceController.save()
            }
        }
    }
    
    @discardableResult private func createRoom(in context: NSManagedObjectContext, identifier: String) -> RoomEntity {
        let now = Date()
        
        let room = context.create(RoomEntity.self)
        room.identifier = identifier
        room.name = "Room: \(identifier)"
        room.unreadCount = 3
        room.isPrivate = false
        room.createdAt = now
        room.updatedAt = now
        
        return room
    }
    
}
