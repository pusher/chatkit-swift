
extension Reducer.UserSubscription {
    
    struct RoomUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = RoomUpdatedAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let masterAction: MasterAction = .roomUpdatedAction(action)
            let joinedRooms = dependencies.roomListReducer(masterAction, state.joinedRooms, dependencies)
            
            return MasterState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionRoomUpdatedReducer {
    
    var userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType { get }
    
}
