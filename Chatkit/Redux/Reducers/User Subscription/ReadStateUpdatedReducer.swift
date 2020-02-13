
extension Reducer.UserSubscription {
    
    struct ReadStateUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = ReadStateUpdatedAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let masterAction: MasterAction = .readStateUpdatedAction(action)
            let joinedRooms = dependencies.roomListReducer(masterAction, state.joinedRooms, dependencies)
            
            return MasterState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionReadStateUpdatedReducer {
    
    var userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType { get }
    
}
