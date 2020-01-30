import Foundation

// TODO: this is temporary, until the transformer is implemented
extension JoinedRoomsProvider: StoreListener {
    
    func store(_ store: Store, didUpdateState state: State) {
        
        for joinedRoom in state.joinedRooms {
            if rooms.contains(where: { $0.identifier != joinedRoom.identifier }) {
                let room = EntityParser.room(fromJoinedRoom: joinedRoom)
                self.rooms.insert(room)
                self.delegate?.joinedRoomsProvider(self, didJoinRoom: room)
            }
        }
        
        for currentRoom in rooms {
            if !state.joinedRooms.contains(where: { $0.identifier == currentRoom.identifier }) {
                self.rooms.remove(currentRoom)
                self.delegate?.joinedRoomsProvider(self, didLeaveRoom: currentRoom)
            }
        }
        
    }
}

// TODO: no thought has gone into this what so ever, please re-write/move/rename etc
class EntityParser {
    
    static func room(fromJoinedRoom joinedRoom: Internal.Room) -> Room {
        // TODO: fill in the blanks
        return Room(identifier: joinedRoom.identifier,
                    name: joinedRoom.name,
                    isPrivate: false,
                    unreadCount: 0,
                    lastMessage: nil,
                    customData: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    deletedAt: nil)
    }
    
}
