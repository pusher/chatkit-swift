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
    @NSManaged var cursors: NSOrderedSet?
    @NSManaged var parts: NSOrderedSet
    @NSManaged var room: RoomEntity
    @NSManaged var sender: UserEntity
    
}

// MARK: Generated accessors for cursors
extension MessageEntity {
    
    @objc(insertObject:inCursorsAtIndex:)
    @NSManaged func insertIntoCursors(_ value: CursorEntity, at idx: Int)
    
    @objc(removeObjectFromCursorsAtIndex:)
    @NSManaged func removeFromCursors(at idx: Int)
    
    @objc(insertCursors:atIndexes:)
    @NSManaged func insertIntoCursors(_ values: [CursorEntity], at indexes: NSIndexSet)
    
    @objc(removeCursorsAtIndexes:)
    @NSManaged func removeFromCursors(at indexes: NSIndexSet)
    
    @objc(replaceObjectInCursorsAtIndex:withObject:)
    @NSManaged func replaceCursors(at idx: Int, with value: CursorEntity)
    
    @objc(replaceCursorsAtIndexes:withCursors:)
    @NSManaged func replaceCursors(at indexes: NSIndexSet, with values: [CursorEntity])
    
    @objc(addCursorsObject:)
    @NSManaged func addToCursors(_ value: CursorEntity)
    
    @objc(removeCursorsObject:)
    @NSManaged func removeFromCursors(_ value: CursorEntity)
    
    @objc(addCursors:)
    @NSManaged func addToCursors(_ values: NSOrderedSet)
    
    @objc(removeCursors:)
    @NSManaged func removeFromCursors(_ values: NSOrderedSet)
    
}

// MARK: Generated accessors for parts
extension MessageEntity {
    
    @objc(insertObject:inPartsAtIndex:)
    @NSManaged func insertIntoParts(_ value: PartEntity, at idx: Int)
    
    @objc(removeObjectFromPartsAtIndex:)
    @NSManaged func removeFromParts(at idx: Int)
    
    @objc(insertParts:atIndexes:)
    @NSManaged func insertIntoParts(_ values: [PartEntity], at indexes: NSIndexSet)
    
    @objc(removePartsAtIndexes:)
    @NSManaged func removeFromParts(at indexes: NSIndexSet)
    
    @objc(replaceObjectInPartsAtIndex:withObject:)
    @NSManaged func replaceParts(at idx: Int, with value: PartEntity)
    
    @objc(replacePartsAtIndexes:withParts:)
    @NSManaged func replaceParts(at indexes: NSIndexSet, with values: [PartEntity])
    
    @objc(addPartsObject:)
    @NSManaged func addToParts(_ value: PartEntity)
    
    @objc(removePartsObject:)
    @NSManaged func removeFromParts(_ value: PartEntity)
    
    @objc(addParts:)
    @NSManaged func addToParts(_ values: NSOrderedSet)
    
    @objc(removeParts:)
    @NSManaged func removeFromParts(_ values: NSOrderedSet)
    
}
