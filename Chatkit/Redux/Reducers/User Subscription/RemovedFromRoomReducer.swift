
extension Reducer.UserSubscription {
    
    struct RemovedFromRoom: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = RemovedFromRoomAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let masterAction: MasterAction = .removedFromRoomAction(action)
            let joinedRooms = dependencies.roomListReducer(masterAction, state.joinedRooms, dependencies)
            
            return MasterState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionRemovedFromRoomReducer {
    
    var userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType { get }
    
}
