
class SubscriptionStateUpdatedAction: Action {
    
    // MARK: - Properties
    
    let type: String // TODO: Replace with SubscriptionType when available.
    let state: String // TODO: Replace with something that can be mapped to SubscriptionState.
    
    // MARK: - Initializers
    
    init(type: String, state: String) {
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
