
protocol HasReducer_Model_User_forInitialState {
    var reducer_model_user_forInitialState:
        Reducer.Model.User_forInitialState.Typing.ExpressionType { get }
}

extension Reducer.Model {

    struct User_forInitialState: Reducing {
        
        struct Typing: ReducerTyping {
            typealias ActionType = ReceivedInitialStateAction
            typealias StateType = UserState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Typing

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
    }
    
}
