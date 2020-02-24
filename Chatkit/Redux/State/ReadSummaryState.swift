
struct ReadSummaryState: State {
    
    // MARK: - Properties
    
    let unreadCount: UInt64
    // TODO: Add cursor when we will start dealing with them.
    
    static let empty: ReadSummaryState = ReadSummaryState(unreadCount: 0)
    
    // MARK: - Accessors
    
    let isComplete = true
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: ReadSummaryState) -> ReadSummaryState {
        return self
    }
    
}

// MARK: - Equatable

extension ReadSummaryState: Equatable {}

// MARK: - Hashable

extension ReadSummaryState: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.unreadCount)
    }
    
}
