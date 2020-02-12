
extension Reducer.UserSubscription {
    
    struct RemovedFromRoom: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = ReceivedRemovedFromRoomAction
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

protocol HasUserSubscriptionRemovedFromRoomReducer {
    
    var userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType { get }
    
}
