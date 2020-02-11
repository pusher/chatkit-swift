
struct ChatState: State {
    
    // MARK: - Properties
    
    let users: [UserState]
    let currentUser: UserState?
    
    let joinedRooms: [RoomState]
    
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: ChatState = ChatState(users: [], currentUser: nil, joinedRooms: [])
    
}

// MARK: - Equatable

extension ChatState: Equatable {}

