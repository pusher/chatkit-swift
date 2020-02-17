
struct UserListState: State {
    
    // MARK: - Properties
    
    let users: [String : UserState]
    
    static let empty: UserListState = UserListState(users: [:])
    
}

// MARK: - Equatable

extension UserListState: Equatable {}
