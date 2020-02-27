
extension Reducer.Subscription {
    
    struct StateUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = SubscriptionStateUpdatedAction
        typealias StateType = AuxiliaryState
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            // TODO: Map subscription type and state to the dictionary below.
            var subscriptions = state.subscriptions
            subscriptions[action.type] = .connected
            
            return AuxiliaryState(subscriptions: subscriptions)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasSubscriptionStateUpdatedReducer {
    
    var subscriptionStateUpdatedReducer: Reducer.Subscription.StateUpdated.ExpressionType { get }
    
}
