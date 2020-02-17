import Foundation

// TODO: `JoinedRoomsTransformer` 
// The `JoinedRoomsTransformer` code should be implemented here
// Until that time we temporarily have this code to pass messages to the JoinedRoomsProvider

extension JoinedRoomsProvider: StoreListener {
    
    func store(_ store: Store, didUpdateState state: MasterState) {
        
        for roomState in state.joinedRooms.rooms.values {
            if rooms.contains(where: { $0.identifier != roomState.identifier }) {
                let room = EntityParser.room(fromRoomState: roomState)
                rooms.insert(room)
                delegate?.joinedRoomsProvider(self, didJoinRoom: room)
            }
        }
        
        for currentRoom in rooms {
            if !state.joinedRooms.rooms.contains(where: { $0.value.identifier == currentRoom.identifier }) {
                rooms.remove(currentRoom)
                delegate?.joinedRoomsProvider(self, didLeaveRoom: currentRoom)
            }
        }
        
    }
}

// TODO: `JoinedRoomsTransformer` 
// TODO: this needs to be completely replaced/rewritten as part of the `JoinedRoomsTransformer` work.
class EntityParser {
    
    static func room(fromRoomState roomState: RoomState) -> Room {
        // TODO: fill in the blanks
        return Room(identifier: roomState.identifier,
                    name: roomState.name,
                    isPrivate: false,
                    unreadCount: 0,
                    lastMessage: nil,
                    customData: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    deletedAt: nil)
    }
    
}
