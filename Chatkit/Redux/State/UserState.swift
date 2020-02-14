
enum UserState: State {
    
    case empty
    // TODO: Consider in future for DependencyFetcher
//    case partial(identifier: String)
    case populated(identifier: String, name: String)
    // TODO: Consider in future for deleted users
//    case redacted
    
}

// MARK: - Accessors

extension UserState {
    
    var identifier: String? {
        switch self {
        case .empty:
            return nil
            
        case let .populated(identifier, _):
            return identifier
        }
    }
    
}

// MARK: - Equatable

extension UserState: Equatable {}
