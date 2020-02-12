
extension Reducer.UserSubscription {
    
    struct ReadStateUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = ReadStateUpdatedAction
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

protocol HasUserSubscriptionReadStateUpdatedReducer {
    
    var userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType { get }
    
}
