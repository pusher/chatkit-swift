import Foundation
import CoreData

extension MessageEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: String(describing: MessageEntity.self))
    }
    
    @NSManaged var createdAt: Date
    @NSManaged var deletedAt: Date?
    @NSManaged var identifier: String
    @NSManaged var updatedAt: Date
    @NSManaged var cursor: CursorEntity?
    @NSManaged var parts: Set<PartEntity>
    @NSManaged var room: RoomEntity
    @NSManaged var sender: UserEntity
    
}

// MARK: Generated accessors for parts
extension MessageEntity {
    
    @objc(addPartsObject:)
    @NSManaged func addToParts(_ value: PartEntity)
    
    @objc(removePartsObject:)
    @NSManaged func removeFromParts(_ value: PartEntity)
    
    @objc(addParts:)
    @NSManaged func addToParts(_ values: Set<PartEntity>)
    
    @objc(removeParts:)
    @NSManaged func removeFromParts(_ values: Set<PartEntity>)
    
}
