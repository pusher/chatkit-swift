import Foundation
import CoreData

extension UserEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: String(describing: UserEntity.self))
    }
    
    @NSManaged var avatar: String?
    @NSManaged var createdAt: Date
    @NSManaged var identifier: String
    @NSManaged var metadata: Data?
    @NSManaged var name: String?
    @NSManaged var presenceState: String?
    @NSManaged var updatedAt: Date
    @NSManaged var createdRooms: Set<RoomEntity>?
    @NSManaged var cursor: Set<CursorEntity>?
    @NSManaged var messages: NSOrderedSet?
    @NSManaged var room: Set<RoomEntity>?
    @NSManaged var typingInRooms: Set<RoomEntity>?
    
}

// MARK: Generated accessors for createdRooms
extension UserEntity {
    
    @objc(addCreatedRoomsObject:)
    @NSManaged func addToCreatedRooms(_ value: RoomEntity)
    
    @objc(removeCreatedRoomsObject:)
    @NSManaged func removeFromCreatedRooms(_ value: RoomEntity)
    
    @objc(addCreatedRooms:)
    @NSManaged func addToCreatedRooms(_ values: Set<RoomEntity>)
    
    @objc(removeCreatedRooms:)
    @NSManaged func removeFromCreatedRooms(_ values: Set<RoomEntity>)
    
}

// MARK: Generated accessors for cursor
extension UserEntity {
    
    @objc(addCursorObject:)
    @NSManaged func addToCursor(_ value: CursorEntity)
    
    @objc(removeCursorObject:)
    @NSManaged func removeFromCursor(_ value: CursorEntity)
    
    @objc(addCursor:)
    @NSManaged func addToCursor(_ values: Set<CursorEntity>)
    
    @objc(removeCursor:)
    @NSManaged func removeFromCursor(_ values: Set<CursorEntity>)
    
}

// MARK: Generated accessors for messages
extension UserEntity {
    
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

// MARK: Generated accessors for room
extension UserEntity {
    
    @objc(addRoomObject:)
    @NSManaged func addToRoom(_ value: RoomEntity)
    
    @objc(removeRoomObject:)
    @NSManaged func removeFromRoom(_ value: RoomEntity)
    
    @objc(addRoom:)
    @NSManaged func addToRoom(_ values: Set<RoomEntity>)
    
    @objc(removeRoom:)
    @NSManaged func removeFromRoom(_ values: Set<RoomEntity>)
    
}

// MARK: Generated accessors for typingInRooms
extension UserEntity {
    
    @objc(addTypingInRoomsObject:)
    @NSManaged func addToTypingInRooms(_ value: RoomEntity)
    
    @objc(removeTypingInRoomsObject:)
    @NSManaged func removeFromTypingInRooms(_ value: RoomEntity)
    
    @objc(addTypingInRooms:)
    @NSManaged func addToTypingInRooms(_ values: Set<RoomEntity>)
    
    @objc(removeTypingInRooms:)
    @NSManaged func removeFromTypingInRooms(_ values: Set<RoomEntity>)
    
}
