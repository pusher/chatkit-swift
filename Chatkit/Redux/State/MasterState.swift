
struct MasterState: State {
    
    // MARK: - Properties
    
    let users: [UserState]
    let currentUser: UserState
    
//    let joinedRooms: [String : RoomState]
    let joinedRooms: RoomListState
//    let readStates: [String : ReadState]
    
    // TODO: Add readStates.
    // TODO: Add memberships.
    
//    static let empty: MasterState = MasterState(users: [], currentUser: nil, joinedRooms: [:], readStates: [:])
    static let empty: MasterState = MasterState(users: [], currentUser: .empty, joinedRooms: .empty)
    
}

// MARK: - Equatable

extension MasterState: Equatable {}

