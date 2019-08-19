import Foundation
import CoreData

extension CursorEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CursorEntity> {
        return NSFetchRequest<CursorEntity>(entityName: String(describing: CursorEntity.self))
    }
    
    @NSManaged var updatedAt: Date
    @NSManaged var readMessages: NSOrderedSet
    @NSManaged var room: RoomEntity
    @NSManaged var user: UserEntity
    
}

// MARK: Generated accessors for readMessages
extension CursorEntity {
    
    @objc(insertObject:inReadMessagesAtIndex:)
    @NSManaged func insertIntoReadMessages(_ value: MessageEntity, at idx: Int)
    
    @objc(removeObjectFromReadMessagesAtIndex:)
    @NSManaged func removeFromReadMessages(at idx: Int)
    
    @objc(insertReadMessages:atIndexes:)
    @NSManaged func insertIntoReadMessages(_ values: [MessageEntity], at indexes: NSIndexSet)
    
    @objc(removeReadMessagesAtIndexes:)
    @NSManaged func removeFromReadMessages(at indexes: NSIndexSet)
    
    @objc(replaceObjectInReadMessagesAtIndex:withObject:)
    @NSManaged func replaceReadMessages(at idx: Int, with value: MessageEntity)
    
    @objc(replaceReadMessagesAtIndexes:withReadMessages:)
    @NSManaged func replaceReadMessages(at indexes: NSIndexSet, with values: [MessageEntity])
    
    @objc(addReadMessagesObject:)
    @NSManaged func addToReadMessages(_ value: MessageEntity)
    
    @objc(removeReadMessagesObject:)
    @NSManaged func removeFromReadMessages(_ value: MessageEntity)
    
    @objc(addReadMessages:)
    @NSManaged func addToReadMessages(_ values: NSOrderedSet)
    
    @objc(removeReadMessages:)
    @NSManaged func removeFromReadMessages(_ values: NSOrderedSet)
    
}
