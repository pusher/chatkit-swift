
protocol HasReducer_UserSubscription_InitialState {

    var reducer_userSubscription_initialState: (ActionType, StateType, DependenciesType) -> Self.StateType { get }
}

extension HasReducer_UserSubscription_InitialState {
    typealias ActionType = ReceivedInitialStateAction
    typealias StateType = ChatState
    typealias DependenciesType = HasReducer_Model_User_forInitialState & HasReducer_Model_Rooms_forInitialState
}

extension Reducer.UserSubscription {

    struct InitialState {

        typealias T = HasReducer_UserSubscription_InitialState

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {

            let currentUser = dependencies.reducer_model_user_forInitialState(action, state.currentUser, dependencies)
            let joinedRooms = dependencies.reducer_model_rooms_forInitialState(action, state.joinedRooms, dependencies)

            return ChatState(currentUser: currentUser, joinedRooms: joinedRooms)
        }
    }
    
}



//typealias HasReducer_UserSubscription_InitialState {
//
//}
//
//struct Reducer_UserSubscription_InitialStateTypes {
//
//    typealias T = Reducer.UserSubscription.InitialState
//}
//
//protocol HasReducer_UserSubscription_InitialState {
//
//
//    var reducer_userSubscription_initialState: (TXX.ActionType, TXX.StateType, TXX.DependenciesType) -> TXX.StateType { get }
//}
//
//
//
//extension Reducer.UserSubscription {
//
//    struct InitialState {
//
//        typealias ActionType = ReceivedInitialStateAction
//        typealias StateType = ChatState
//        typealias DependenciesType = HasReducer_Model_User_forInitialState & HasReducer_Model_Rooms_forInitialState
//
//        static func reduce(action: ActionType,
//                          state: StateType,
//                          dependencies: DependenciesType) -> ChatState {
//
//            let currentUser = dependencies.reducer_model_user_forInitialState(action, state.currentUser)
//            let joinedRooms = dependencies.reducer_model_rooms_forInitialState(action, state.joinedRooms)
//
//            return ChatState(currentUser: currentUser, joinedRooms: joinedRooms)
//        }
//    }
//
//}
