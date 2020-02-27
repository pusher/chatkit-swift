
enum SubscriptionState: State {
    
    case initializing(error: Error?)
    case connected
    case degraded(error: Error)
    case closed(error: Error?)
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        return true
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: SubscriptionState) -> SubscriptionState {
        return self
    }
    
}

// MARK: - Equatable

extension SubscriptionState: Equatable {
    
    static func == (lhs: SubscriptionState, rhs: SubscriptionState) -> Bool {
        switch (lhs, rhs) {
        case (let .initializing(lhsError as NSError?),
              let .initializing(rhsError as NSError?)),
             (let .closed(lhsError as NSError?),
              let .closed(rhsError as NSError?)):
            return lhsError == rhsError
            
        case (.connected, .connected):
            return true
            
        case (let .degraded(lhsError as NSError),
              let .degraded(rhsError as NSError)):
            return lhsError == rhsError
            
        default:
            return false
        }
    }
    
}

// MARK: - Hashable

extension SubscriptionState: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .initializing(error as NSError?):
            hasher.combine(0) // Discriminator
            hasher.combine(error)
            
        case .connected:
            hasher.combine(1) // Discriminator
            
        case let .degraded(error as NSError):
            hasher.combine(2) // Discriminator
            hasher.combine(error)
            
        case let .closed(error as NSError?):
            hasher.combine(3) // Discriminator
            hasher.combine(error)
        }
    }
    
}
