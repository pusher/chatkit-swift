
struct MasterState: State {
    
    // MARK: - Properties
    
    let currentUser: UserState
    let joinedRooms: RoomListState
    
    let users: UserListState
    
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: MasterState = MasterState(currentUser: .empty, joinedRooms: .empty, users: .empty)
    
}

// MARK: - Equatable

extension MasterState: Equatable {}

