
extension Reducer {
    
    struct Master: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = MasterAction
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
            
            switch action {
                
            case let .initialStateAction(action):
                return dependencies.initialStateUserSubscriptionReducer(action, state, dependencies)
                
            case let .addedToRoomAction((action)):
                return dependencies.userSubscriptionAddedToRoomReducer(action, state, dependencies)
                
            case let .removedFromRoomAction((action)):
                return dependencies.userSubscriptionRemovedFromRoomReducer(action, state, dependencies)
                
            case let .roomUpdatedAction((action)):
                return dependencies.userSubscriptionRoomUpdatedReducer(action, state, dependencies)
                
            case let .roomDeletedAction((action)):
                return dependencies.userSubscriptionRoomDeletedReducer(action, state, dependencies)
                
            case let .readStateUpdatedAction((action)):
                return dependencies.userSubscriptionReadStateUpdatedReducer(action, state, dependencies)
            }
        
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasMasterReducer {
    
    var masterReducer: Reducer.Master.ExpressionType { get }
    
}
