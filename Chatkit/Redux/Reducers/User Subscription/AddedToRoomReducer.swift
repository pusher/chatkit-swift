
extension Reducer.UserSubscription {
    
    struct AddedToRoom: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = AddedToRoomAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let joinedRooms = dependencies.roomListReducer(action, state.joinedRooms, dependencies)
            
            return MasterState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionAddedToRoomReducer {
    
    var userSubscriptionAddedToRoomReducer: Reducer.UserSubscription.AddedToRoom.ExpressionType { get }
    
}
