
extension Reducer {
    
    struct Master: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = MasterState
        typealias DependenciesType =
            HasUserReducer
            & HasRoomListReducer
            & HasUserSubscriptionInitialStateReducer
            & HasUserSubscriptionRemovedFromRoomReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            if let action = action as? ReceivedInitialStateAction {
                return dependencies.initialStateUserSubscriptionReducer(action, state, dependencies)
            }
            else if let action = action as? ReceivedRemovedFromRoomAction {
                return dependencies.userSubscriptionRemovedFromRoomReducer(action, state, dependencies)
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasMasterReducer {
    
    var masterReducer: Reducer.Master.ExpressionType { get }
    
}
