
struct RoomListState: State {
    
    // MARK: - Properties
    
    let rooms: [String : RoomState]
    
    static let empty: RoomListState = RoomListState(rooms: [:])
    
}

// MARK: - Equatable

extension RoomListState: Equatable {}
