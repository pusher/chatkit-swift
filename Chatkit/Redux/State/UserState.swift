
enum UserState {
    
    case empty
    // TODO: Consider in future for DependencyFetcher
//    case partial(identifier: String)
    case populated(identifier: String, name: String)
    // TODO: Consider in future for deleted users
//    case redacted
    
}

// MARK: - Equatable

extension UserState: Equatable {}
