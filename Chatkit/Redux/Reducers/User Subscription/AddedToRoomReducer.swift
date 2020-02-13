
extension Reducer.UserSubscription {
    
    struct AddedToRoom: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = AddedToRoomAction
        typealias StateType = MasterState
        typealias DependenciesType = HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let masterAction: MasterAction = .addedToRoomAction(action)
            let joinedRooms = dependencies.roomListReducer(masterAction, state.joinedRooms, dependencies)
            
            return MasterState(currentUser: state.currentUser, joinedRooms: joinedRooms, users: state.users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionAddedToRoomReducer {
    
    var userSubscriptionAddedToRoomReducer: Reducer.UserSubscription.AddedToRoom.ExpressionType { get }
    
}
