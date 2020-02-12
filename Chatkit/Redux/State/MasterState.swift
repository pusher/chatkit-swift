
struct MasterState: State {
    
    // MARK: - Properties
    
    let users: [UserState]
    let currentUser: UserState
    
    let joinedRooms: RoomListState
    
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: MasterState = MasterState(users: [], currentUser: .empty, joinedRooms: .empty)
    
}

// MARK: - Equatable

extension MasterState: Equatable {}

