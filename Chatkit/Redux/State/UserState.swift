
enum UserState: State {
    
    case empty
    case partial(identifier: String)
    case populated(identifier: String, name: String)
    // TODO: Consider in future for deleted users
//    case redacted
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        switch self {
        case .empty,
             .populated(_, _):
            return true
            
        case .partial(_):
            return false
        }
    }
    
    var identifier: String? {
        switch self {
        case .empty:
            return nil
            
        case let .populated(identifier, _),
             let .partial(identifier):
            return identifier
        }
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: UserState) -> UserState {
        if case .populated(_, _) = self {
            return self
        }
        
        guard let identifier = self.identifier,
            let supplementalIdentifier = supplementalState.identifier,
            supplementalIdentifier == identifier else {
                return self
        }
        
        return supplementalState
    }
    
}

// MARK: - Equatable

extension UserState: Equatable {}
