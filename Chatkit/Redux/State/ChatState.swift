
struct ChatState: State {
    
    // MARK: - Properties
    
    let currentUser: UserState
    let joinedRooms: RoomListState
    
    let users: UserListState
    
    // TODO: Add cursors.
    // TODO: Add memberships.
    
    static let empty: ChatState = ChatState(currentUser: .empty, joinedRooms: .empty, users: .empty)
    
}

// MARK: - Equatable

extension ChatState: Equatable {}

