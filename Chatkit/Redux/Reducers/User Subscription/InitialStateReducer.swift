
extension Reducer.UserSubscription {
    
    struct InitialState: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = InitialStateAction
        typealias StateType = MasterState
        typealias DependenciesType = HasUserReducer
            & HasRoomListReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            let currentUser = dependencies.userReducer(action, state.currentUser, dependencies)
            
            let masterAction: MasterAction = .initialStateAction(action)
            let joinedRooms = dependencies.roomListReducer(masterAction, state.joinedRooms, dependencies)
            
            var users: UserListState
            if let identifier = currentUser.identifier {
                users = UserListState(users: [identifier : currentUser])
            }
            else {
                users = .empty
            }
            
            return MasterState(currentUser: currentUser, joinedRooms: joinedRooms, users: users)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserSubscriptionInitialStateReducer {
    
    var initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType { get }
    
}
