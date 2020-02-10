
protocol HasReducer_Master {
    var reducer_master: Reducer.Master.ExpressionType { get }
}

extension Reducer {
    
    struct Master: Reducing {
        
        typealias ActionType = Action
        typealias StateType = ChatState
        typealias DependenciesType =
            HasReducer_Model_User_forInitialState
            & HasReducer_Model_Rooms_forInitialState
            & HasReducer_Model_Rooms_forRemovedFromRoom
            & HasReducer_UserSubscription_InitialState
            & HasReducer_UserSubscription_RemovedFromRoom
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
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
