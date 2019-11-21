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
                    unreadCount: 3,
                    lastMessage: nil,
                    customData: nil,
                    createdAt: now,
                    updatedAt: now,
                    deletedAt: nil,
                    objectID: nil!) // FIXME: Make this optional for data that is not supposed to be persisted.
            }
            
            completionHandler(rooms)
        }
    }
    
}
