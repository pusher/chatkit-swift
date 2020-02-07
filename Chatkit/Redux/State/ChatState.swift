
struct ChatState: State {
    
    // MARK: - Properties
    
    let currentUser: UserState
    let joinedRooms: [RoomState]
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: ChatState = ChatState(currentUser: .empty, joinedRooms: [])
    
}

// MARK: - Equatable

extension ChatState: Equatable {}
