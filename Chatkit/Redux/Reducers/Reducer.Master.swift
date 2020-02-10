
protocol HasReducer_Master {
    var reducer_master: T.ReduceFunctionSignature { get }
}

extension HasReducer_Master {
    typealias T = Reducer.Master.Types
}

extension Reducer {
    
    struct Master {
        
        struct Types: ReducerTypes {
            typealias ActionType = Action
            typealias StateType = ChatState
            typealias DependenciesType =
                HasReducer_Model_User_forInitialState
                & HasReducer_Model_Rooms_forInitialState
                & HasReducer_Model_Rooms_forRemovedFromRoom
                & HasReducer_UserSubscription_InitialState
                & HasReducer_UserSubscription_RemovedFromRoom
        }
        
        typealias T = Types
        
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
