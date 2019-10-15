import Foundation
import CoreData

extension RoomEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: String(describing: RoomEntity.self))
    }
    
    @NSManaged var createdAt: Date
    @NSManaged var deletedAt: Date?
    @NSManaged var identifier: String
    @NSManaged var isPrivate: Bool
    @NSManaged var userData: Data?
    @NSManaged var name: String
    @NSManaged var unreadCount: Int64
    @NSManaged var updatedAt: Date
    @NSManaged var cursors: Set<CursorEntity>?
    @NSManaged var members: NSOrderedSet?
    @NSManaged var messages: NSOrderedSet?
    @NSManaged var typingMembers: NSOrderedSet?
    
}

// MARK: Generated accessors for cursors
extension RoomEntity {
    
    @objc(addCursorsObject:)
    @NSManaged func addToCursors(_ value: CursorEntity)
    
    @objc(removeCursorsObject:)
    @NSManaged func removeFromCursors(_ value: CursorEntity)
    
    @objc(addCursors:)
    @NSManaged func addToCursors(_ values: Set<CursorEntity>)
    
    @objc(removeCursors:)
    @NSManaged func removeFromCursors(_ values: Set<CursorEntity>)
    
}

// MARK: Generated accessors for members
extension RoomEntity {
    
    @objc(insertObject:inMembersAtIndex:)
    @NSManaged func insertIntoMembers(_ value: UserEntity, at idx: Int)
    
    @objc(removeObjectFromMembersAtIndex:)
    @NSManaged func removeFromMembers(at idx: Int)
    
    @objc(insertMembers:atIndexes:)
    @NSManaged func insertIntoMembers(_ values: [UserEntity], at indexes: NSIndexSet)
    
    @objc(removeMembersAtIndexes:)
    @NSManaged func removeFromMembers(at indexes: NSIndexSet)
    
    @objc(replaceObjectInMembersAtIndex:withObject:)
    @NSManaged func replaceMembers(at idx: Int, with value: UserEntity)
    
    @objc(replaceMembersAtIndexes:withMembers:)
    @NSManaged func replaceMembers(at indexes: NSIndexSet, with values: [UserEntity])
    
    @objc(addMembersObject:)
    @NSManaged func addToMembers(_ value: UserEntity)
    
    @objc(removeMembersObject:)
    @NSManaged func removeFromMembers(_ value: UserEntity)
    
    @objc(addMembers:)
    @NSManaged func addToMembers(_ values: NSOrderedSet)
    
    @objc(removeMembers:)
    @NSManaged func removeFromMembers(_ values: NSOrderedSet)
    
}

// MARK: Generated accessors for messages
extension RoomEntity {
    
    @objc(insertObject:inMessagesAtIndex:)
    @NSManaged func insertIntoMessages(_ value: MessageEntity, at idx: Int)
    
    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged func removeFromMessages(at idx: Int)
    
    @objc(insertMessages:atIndexes:)
    @NSManaged func insertIntoMessages(_ values: [MessageEntity], at indexes: NSIndexSet)
    
    @objc(removeMessagesAtIndexes:)
    @NSManaged func removeFromMessages(at indexes: NSIndexSet)
    
    @objc(replaceObjectInMessagesAtIndex:withObject:)
    @NSManaged func replaceMessages(at idx: Int, with value: MessageEntity)
    
    @objc(replaceMessagesAtIndexes:withMessages:)
    @NSManaged func replaceMessages(at indexes: NSIndexSet, with values: [MessageEntity])
    
    @objc(addMessagesObject:)
    @NSManaged func addToMessages(_ value: MessageEntity)
    
    @objc(removeMessagesObject:)
    @NSManaged func removeFromMessages(_ value: MessageEntity)
    
    @objc(addMessages:)
    @NSManaged func addToMessages(_ values: NSOrderedSet)
    
    @objc(removeMessages:)
    @NSManaged func removeFromMessages(_ values: NSOrderedSet)
    
}

// MARK: Generated accessors for typingMembers
extension RoomEntity {
    
    @objc(insertObject:inTypingMembersAtIndex:)
    @NSManaged func insertIntoTypingMembers(_ value: UserEntity, at idx: Int)
    
    @objc(removeObjectFromTypingMembersAtIndex:)
    @NSManaged func removeFromTypingMembers(at idx: Int)
    
    @objc(insertTypingMembers:atIndexes:)
    @NSManaged func insertIntoTypingMembers(_ values: [UserEntity], at indexes: NSIndexSet)
    
    @objc(removeTypingMembersAtIndexes:)
    @NSManaged func removeFromTypingMembers(at indexes: NSIndexSet)
    
    @objc(replaceObjectInTypingMembersAtIndex:withObject:)
    @NSManaged func replaceTypingMembers(at idx: Int, with value: UserEntity)
    
    @objc(replaceTypingMembersAtIndexes:withTypingMembers:)
    @NSManaged func replaceTypingMembers(at indexes: NSIndexSet, with values: [UserEntity])
    
    @objc(addTypingMembersObject:)
    @NSManaged func addToTypingMembers(_ value: UserEntity)
    
    @objc(removeTypingMembersObject:)
    @NSManaged func removeFromTypingMembers(_ value: UserEntity)
    
    @objc(addTypingMembers:)
    @NSManaged func addToTypingMembers(_ values: NSOrderedSet)
    
    @objc(removeTypingMembers:)
    @NSManaged func removeFromTypingMembers(_ values: NSOrderedSet)
    
}
