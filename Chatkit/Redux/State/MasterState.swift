
struct MasterState: State {
    
    // MARK: - Properties
    
    let users: [UserState]
    let currentUser: UserState?
    
    let joinedRooms: [RoomState]
    
    // TODO: Add readStates.
    // TODO: Add memberships.
    
    static let empty: MasterState = MasterState(users: [], currentUser: nil, joinedRooms: [])
    
}

// MARK: - Equatable

extension MasterState: Equatable {}

