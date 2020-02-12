
extension Reducer.UserSubscription {
    
    struct InitialState: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = ReceivedInitialStateAction
        typealias StateType = MasterState
        typealias DependenciesType = HasUserReducer
            & HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let currentUser = dependencies.userReducer(action, state.currentUser, dependencies)
            let joinedRooms = dependencies.roomListReducer(action, state.joinedRooms, dependencies)
            
            let users: [UserState] = currentUser == .empty ? [] : [currentUser]
            
            return MasterState(users: users, currentUser: currentUser, joinedRooms: joinedRooms)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionInitialStateReducer {
    
    var initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType { get }
    
}
