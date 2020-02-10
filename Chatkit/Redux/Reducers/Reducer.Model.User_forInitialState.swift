
protocol HasReducer_Model_User_forInitialState {

    var reducer_model_user_forInitialState: (ActionType, StateType, DependenciesType) -> Self.StateType { get }
}

extension HasReducer_Model_User_forInitialState {
    typealias ActionType = ReceivedInitialStateAction
    typealias StateType = UserState
    typealias DependenciesType = Any // No dependencies at present
}

extension Reducer.Model {

    struct User_forInitialState {

        typealias T = HasReducer_Model_User_forInitialState

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
    }
    
}

//protocol HasReducer_Model_User_forInitialState {
//    var reducer_model_user_forInitialState: (ReceivedInitialStateAction, UserState) -> UserState { get }
//}
//
//extension Reducer.Model {
//
//    static func user(action: ReceivedInitialStateAction, state: UserState) -> UserState {
//    }
//}
//
