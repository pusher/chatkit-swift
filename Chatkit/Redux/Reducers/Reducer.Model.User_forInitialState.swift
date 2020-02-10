
protocol HasReducer_Model_User_forInitialState {
    var reducer_model_user_forInitialState: T.ReduceFunctionSignature { get }
}

extension HasReducer_Model_User_forInitialState {
    typealias T = Reducer.Model.User_forInitialState.Types
}

extension Reducer.Model {

    struct User_forInitialState {
        
        struct Types: ReducerTypes {
            typealias ActionType = ReceivedInitialStateAction
            typealias StateType = UserState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Types

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
    }
    
}
