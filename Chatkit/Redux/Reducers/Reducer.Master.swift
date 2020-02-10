
protocol HasReducer_Master {
    var reducer_master: (ActionType, StateType, DependenciesType) -> ChatState { get }
}

extension HasReducer_Master {
    typealias ActionType = Action
    typealias StateType = ChatState
    typealias DependenciesType = ReducerDependencies
}

extension Reducer {
    
    struct Master {

        typealias T = HasReducer_Master
        
        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> ChatState {
            
            if let action = action as? ReceivedInitialStateAction {
                return dependencies.reducer_userSubscription_initialState(action, state, dependencies)
            }
            else if let action = action as? ReceivedRemovedFromRoomAction {
                return dependencies.reducer_userSubscription_removedFromRoom(action, state, dependencies)
            }
            
            return state
        }
    }
}
