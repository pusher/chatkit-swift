
extension Reducer {
    
    struct UserSubscription {
        
        // MARK: - Reducers
        
        static func initialState(action: Action, state: ChatState) -> ChatState {
            guard case .receivedInitialState(_) = action else {
                return state
            }
            
            let currentUser = Reducer.Model.user(action: action, state: state.currentUser)
            let joinedRooms = Reducer.Model.roomList(action: action, state: state.joinedRooms)
            
            return ChatState(currentUser: currentUser, joinedRooms: joinedRooms)
        }
        
        static func removedFromRoom(action: Action, state: ChatState) -> ChatState {
            guard case .receivedRemovedFromRoom(_) = action else {
                return state
            }
            
            let joinedRooms = Reducer.Model.roomList(action: action, state: state.joinedRooms)
            
            return ChatState(currentUser: state.currentUser, joinedRooms: joinedRooms)
        }
        
    }
    
}
