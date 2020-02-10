
protocol HasReducer_UserSubscription_InitialState {
    var reducer_userSubscription_initialState:
        Reducer.UserSubscription.InitialState.Typing.ExpressionType { get }
}

extension Reducer.UserSubscription {

    struct InitialState {
        
        struct Typing: ReducerTyping {
            typealias ActionType = ReceivedInitialStateAction
            typealias StateType = ChatState
            typealias DependenciesType = HasReducer_Model_User_forInitialState
                & HasReducer_Model_Rooms_forInitialState
        }

        typealias T = Typing
        
        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {

            let currentUser = dependencies.reducer_model_user_forInitialState(action, state.currentUser, dependencies)
            let joinedRooms = dependencies.reducer_model_rooms_forInitialState(action, state.joinedRooms, dependencies)

            return ChatState(currentUser: currentUser, joinedRooms: joinedRooms)
        }
    }
    
}
