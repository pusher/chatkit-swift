
struct RoomListState: State {
    
    // MARK: - Properties
    
    let rooms: [RoomState]
    
    static let empty: RoomListState = RoomListState(rooms: [])
    
}

// MARK: - Equatable

extension RoomListState: Equatable {}
