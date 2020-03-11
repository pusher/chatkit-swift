
class SubscriptionStateUpdatedAction: Action {
    
    // MARK: - Properties
    
    let type: SubscriptionType
    let state: SubscriptionState
    
    // MARK: - Initializers
    
    init(type: SubscriptionType, state: SubscriptionState) {
        self.type = type
        self.state = state
    }
    
}

// MARK: - Equatable

extension SubscriptionStateUpdatedAction: Equatable {
    
    static func == (lhs: SubscriptionStateUpdatedAction, rhs: SubscriptionStateUpdatedAction) -> Bool {
        return lhs.type == rhs.type && lhs.state == rhs.state
    }
    
}
