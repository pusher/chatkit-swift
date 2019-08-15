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
    @NSManaged var lastMessageAt: Date?
    @NSManaged var metadata: Data?
    @NSManaged var name: String?
    @NSManaged var unreadCount: Int64
    @NSManaged var updatedAt: Date
    @NSManaged var creator: UserEntity
    @NSManaged var cursors: Set<CursorEntity>?
    @NSManaged var members: Set<UserEntity>?
    @NSManaged var messages: NSOrderedSet?
    @NSManaged var typingMembers: Set<UserEntity>?
    
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
    
    @objc(addMembersObject:)
    @NSManaged func addToMembers(_ value: UserEntity)
    
    @objc(removeMembersObject:)
    @NSManaged func removeFromMembers(_ value: UserEntity)
    
    @objc(addMembers:)
    @NSManaged func addToMembers(_ values: Set<UserEntity>)
    
    @objc(removeMembers:)
    @NSManaged func removeFromMembers(_ values: Set<UserEntity>)
    
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
    
    @objc(addTypingMembersObject:)
    @NSManaged func addToTypingMembers(_ value: UserEntity)
    
    @objc(removeTypingMembersObject:)
    @NSManaged func removeFromTypingMembers(_ value: UserEntity)
    
    @objc(addTypingMembers:)
    @NSManaged func addToTypingMembers(_ values: Set<UserEntity>)
    
    @objc(removeTypingMembers:)
    @NSManaged func removeFromTypingMembers(_ values: Set<UserEntity>)
    
}
