
extension Reducer {
    
    struct Master: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = MasterState
        typealias DependenciesType =
            HasUserReducer
            & HasRoomListReducer
            & HasUserSubscriptionInitialStateReducer
            & HasUserSubscriptionAddedToRoomReducer
            & HasUserSubscriptionRemovedFromRoomReducer
            & HasUserSubscriptionRoomUpdatedReducer
            & HasUserSubscriptionRoomDeletedReducer
            & HasUserSubscriptionReadStateUpdatedReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            if let action = action as? InitialStateAction {
                return dependencies.initialStateUserSubscriptionReducer(action, state, dependencies)
            }
            else if let action = action as? AddedToRoomAction {
                return dependencies.userSubscriptionAddedToRoomReducer(action, state, dependencies)
            }
            else if let action = action as? RemovedFromRoomAction {
                return dependencies.userSubscriptionRemovedFromRoomReducer(action, state, dependencies)
            }
            else if let action = action as? RoomUpdatedAction {
                return dependencies.userSubscriptionRoomUpdatedReducer(action, state, dependencies)
            }
            else if let action = action as? RoomDeletedAction {
                return dependencies.userSubscriptionRoomDeletedReducer(action, state, dependencies)
            }
            else if let action = action as? ReadStateUpdatedAction {
                return dependencies.userSubscriptionReadStateUpdatedReducer(action, state, dependencies)
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasMasterReducer {
    
    var masterReducer: Reducer.Master.ExpressionType { get }
    
}
