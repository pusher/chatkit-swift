
extension Reducer.UserSubscription {
    
    struct RemovedFromRoom: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = RemovedFromRoomAction
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

protocol HasUserSubscriptionRemovedFromRoomReducer {
    
    var userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType { get }
    
}
