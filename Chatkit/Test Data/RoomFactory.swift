import Foundation

class RoomFactory {
    
    func receiveRooms(numberOfRooms: Int, lastRoomIdentifier: String, delay: TimeInterval, completionHandler: @escaping ([Room]) -> Void) {
        guard let lastRoomIdentifier = Int(lastRoomIdentifier) else {
            completionHandler([])
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let now = Date()
            let firstRoomIdentifier = lastRoomIdentifier + 1
            
            let rooms = (firstRoomIdentifier..<(firstRoomIdentifier + numberOfRooms)).map {
                Room(identifier: "\($0)",
                    name: "Room \($0)",
                    isPrivate: false,
                    creator: nil,
                    members: [],
                    typingMembers: [],
                    unreadCount: 3,
                    lastMessage: nil,
                    userData: nil,
                    createdAt: now,
                    updatedAt: now,
                    deletedAt: nil,
                    objectID: UserEntityFactory.currentUserID) // It does not really matter what kind of NSManagedObjectID instance we put here.
            }
            
            completionHandler(rooms)
        }
    }
    
}
