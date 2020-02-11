
protocol HasReducer_UserSubscription_InitialState {
    var reducer_userSubscription_initialState:
        Reducer.UserSubscription.InitialState.ExpressionType { get }
}

extension Reducer.UserSubscription {

    struct InitialState: Reducing {
        
        typealias ActionType = ReceivedInitialStateAction
        typealias StateType = ChatState
        typealias DependenciesType = HasReducer_Model_User_forInitialState
            & HasReducer_Model_Rooms_forInitialState
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {

            let currentUser = dependencies.reducer_model_user_forInitialState(action, state.currentUser, dependencies)
            let joinedRooms = dependencies.reducer_model_rooms_forInitialState(action, state.joinedRooms, dependencies)
            
            let users: [UserState]
            if let currentUser = currentUser {
                users = [currentUser]
            } else {
                users = []
            }
            
            return ChatState(users: users, currentUser: currentUser, joinedRooms: joinedRooms)
        }
    }
    
}
