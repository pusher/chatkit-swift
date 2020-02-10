
protocol HasReducer_Model_User_forInitialState {
    var reducer_model_user_forInitialState:
        Reducer.Model.User_forInitialState.ExpressionType { get }
}

extension Reducer.Model {

    struct User_forInitialState: Reducing {
        
        typealias ActionType = ReceivedInitialStateAction
        typealias StateType = UserState
        typealias DependenciesType = Any // No dependencies at present
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
    }
    
}
