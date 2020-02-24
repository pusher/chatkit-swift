
struct UserListState: State {
    
    // MARK: - Properties
    
    let users: [String : UserState]
    
    static let empty: UserListState = UserListState(users: [:])
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        return self.users.values.allSatisfy { $0.isComplete }
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: UserListState) -> UserListState {
        let users = self.users.mapValues { (user) -> UserState in
            if let identifier = user.identifier,
                let supplementalUser = supplementalState.users[identifier] {
                return user.supplement(withState: supplementalUser)
            }
            
            return user
        }
        
        return UserListState(users: users)
    }
    
}

// MARK: - Equatable

extension UserListState: Equatable {}

// MARK: - Hashable

extension UserListState: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.users)
    }
    
}
