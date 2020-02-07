
extension Reducer {
    
    struct Model {
        
        // MARK: - Reducers
        
        static func user(action: ReceivedInitialStateAction, state: UserState) -> UserState {
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
        
        static func roomList(action: ReceivedInitialStateAction, state: RoomListState) -> RoomListState {
            let rooms = action.event.rooms.map { RoomState(identifier: $0.identifier, name: $0.name) }
            
            return RoomListState(rooms: rooms)
        }
        
        static func roomList(action: ReceivedRemovedFromRoomAction, state: RoomListState) -> RoomListState {
            let rooms = state.rooms.filter { $0.identifier != action.event.roomIdentifier }
            
            return RoomListState(rooms: rooms)
        }
        
    }
    
}
