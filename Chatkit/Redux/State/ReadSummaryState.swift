
struct ReadSummaryState: State {
    
    // MARK: - Properties
    
    let unreadCount: UInt64?
    // TODO: Add cursor when we will start dealing with them.
    
    static let empty: ReadSummaryState = ReadSummaryState(unreadCount: nil)
    
}

// MARK: - Equatable

extension ReadSummaryState: Equatable {}
