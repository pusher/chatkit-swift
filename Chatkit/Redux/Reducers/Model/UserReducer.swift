
extension Reducer.Model {
    
    struct User: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = ReceivedInitialStateAction
        typealias StateType = UserState
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasUserReducer {
    
    var userReducer: Reducer.Model.User.ExpressionType { get }
    
}
