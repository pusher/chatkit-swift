
extension Reducer {
    
    struct Model {
        
        // MARK: - Reducers
        
        static func user(action: Action, state: UserState) -> UserState {
            guard case let .receivedInitialState(event) = action else {
                return state
            }
            
            return .populated(identifier: event.currentUser.identifier, name: event.currentUser.name)
        }
        
        static func roomList(action: Action, state: RoomListState) -> RoomListState {
            switch action {
            case let .receivedInitialState(event):
                let rooms = event.rooms.map { RoomState(identifier: $0.identifier, name: $0.name) }
                
                return RoomListState(rooms: rooms)
                
            case let .receivedRemovedFromRoom(event):
                let rooms = state.rooms.filter { $0.identifier != event.roomIdentifier }
                
                return RoomListState(rooms: rooms)
                
            default:
                return state
            }
        }
        
    }
    
}
