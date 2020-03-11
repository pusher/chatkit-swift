
extension Reducer.Subscription {
    
    struct StateUpdated: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = SubscriptionStateUpdatedAction
        typealias StateType = AuxiliaryState
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            var subscriptions = state.subscriptions
            
            // TODO: Handle error scenarios when available.
            switch action.state {
            case .notSubscribed:
                subscriptions[action.type] = .closed(error: nil)
                
            case .subscribingStageOne,
                 .subscribingStageTwo:
                subscriptions[action.type] = .initializing(error: nil)
                
            case .subscribed:
                subscriptions[action.type] = .connected
            }
            
            return AuxiliaryState(subscriptions: subscriptions)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasSubscriptionStateUpdatedReducer {
    
    var subscriptionStateUpdatedReducer: Reducer.Subscription.StateUpdated.ExpressionType { get }
    
}
