
extension Reducer.UserSubscription {
    
    struct RoomDeleted: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = RoomDeletedAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let joinedRooms = dependencies.roomListReducer(action, state.joinedRooms, dependencies)
            
            return MasterState(users: state.users, currentUser: state.currentUser, joinedRooms: joinedRooms)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionRoomDeletedReducer {
    
    var userSubscriptionRoomDeletedReducer: Reducer.UserSubscription.RoomDeleted.ExpressionType { get }
    
}
