import Foundation
import CoreData

extension CursorEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CursorEntity> {
        return NSFetchRequest<CursorEntity>(entityName: String(describing: CursorEntity.self))
    }
    
    @NSManaged var updatedAt: Date
    @NSManaged var message: MessageEntity
    @NSManaged var room: RoomEntity
    @NSManaged var user: UserEntity
    
}
