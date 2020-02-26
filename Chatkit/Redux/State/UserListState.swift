
struct UserListState: ListState {
    
    // MARK: - Types
    
    typealias StateElement = UserState
    
    // MARK: - Properties
    
    let elements: [String : UserState]
    
    let iteratorIndexes: [String]
    var iteratorIndex: Int?
    
    static let empty: UserListState = UserListState(elements: [])
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        return self.allSatisfy { $0.isComplete }
    }
    
    // MARK: - Initializers
    
    init(elements: [String : UserState]) {
        self.elements = elements
        
        self.iteratorIndex = nil
        self.iteratorIndexes = Array(elements.keys)
    }
    
    init(elements: [UserState]) {
        var filteredElements: [String : UserState] = [:]
        
        for element in elements {
            switch element {
            case let .partial(identifier),
                 let .populated(identifier, _):
                filteredElements[identifier] = element
                
            case .empty:
                continue
            }
        }
        
        self.init(elements: filteredElements)
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: UserListState) -> UserListState {
        let users = self.map { (user) -> UserState in
            if let identifier = user.identifier,
                let supplementalUser = supplementalState[identifier] {
                return user.supplement(withState: supplementalUser)
            }
            
            return user
        }
        
        return UserListState(elements: users)
    }
    
}

// MARK: - Equatable

extension UserListState: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.elements == rhs.elements
    }
    
}

// MARK: - Hashable

extension UserListState: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.elements)
    }
    
}
