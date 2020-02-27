
extension Reducer.UserSubscription {
    
    struct RoomUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = RoomUpdatedAction
        typealias StateType = ChatState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let joinedRooms = dependencies.roomListReducer(action, state.joinedRooms, dependencies)
            
            return ChatState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionRoomUpdatedReducer {
    
    var userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType { get }
    
}
