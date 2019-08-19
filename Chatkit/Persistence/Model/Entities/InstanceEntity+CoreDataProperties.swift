import Foundation
import CoreData

extension InstanceEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<InstanceEntity> {
        return NSFetchRequest<InstanceEntity>(entityName: String(describing: InstanceEntity.self))
    }
    
    @NSManaged var locator: String
    @NSManaged var rooms: Set<RoomEntity>?
    @NSManaged var users: Set<UserEntity>?
    
}

// MARK: Generated accessors for rooms
extension InstanceEntity {
    
    @objc(addRoomsObject:)
    @NSManaged func addToRooms(_ value: RoomEntity)
    
    @objc(removeRoomsObject:)
    @NSManaged func removeFromRooms(_ value: RoomEntity)
    
    @objc(addRooms:)
    @NSManaged func addToRooms(_ values: Set<RoomEntity>)
    
    @objc(removeRooms:)
    @NSManaged func removeFromRooms(_ values: Set<RoomEntity>)
    
}

// MARK: Generated accessors for users
extension InstanceEntity {
    
    @objc(addUsersObject:)
    @NSManaged func addToUsers(_ value: UserEntity)
    
    @objc(removeUsersObject:)
    @NSManaged func removeFromUsers(_ value: UserEntity)
    
    @objc(addUsers:)
    @NSManaged func addToUsers(_ values: Set<UserEntity>)
    
    @objc(removeUsers:)
    @NSManaged func removeFromUsers(_ values: Set<UserEntity>)
    
}
