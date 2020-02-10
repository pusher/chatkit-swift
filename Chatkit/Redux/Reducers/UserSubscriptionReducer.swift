
extension Reducer {
    
    struct UserSubscription {
        
        // MARK: - Reducers
        
        static func initialState(action: ReceivedInitialStateAction, state: ChatState) -> ChatState {
            let currentUser = Reducer.Model.user(action: action, state: state.currentUser)
            let joinedRooms = Reducer.Model.roomList(action: action, state: state.joinedRooms)
            
            return ChatState(users: [currentUser], currentUser: currentUser, joinedRooms: joinedRooms)
        }
        
        static func removedFromRoom(action: ReceivedRemovedFromRoomAction, state: ChatState) -> ChatState {
            let joinedRooms = Reducer.Model.roomList(action: action, state: state.joinedRooms)
            
            return ChatState(users: state.users, currentUser: state.currentUser, joinedRooms: joinedRooms)
        }
        
    }
    
}
