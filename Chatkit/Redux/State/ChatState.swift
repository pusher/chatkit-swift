
struct ChatState: State {
    
    // MARK: - Properties
    
    let currentUser: UserState
    let joinedRooms: RoomListState
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: ChatState = ChatState(currentUser: .empty, joinedRooms: .empty)
    
}

// MARK: - Equatable

extension ChatState: Equatable {}
