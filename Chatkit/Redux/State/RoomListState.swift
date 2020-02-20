
struct RoomListState: State {
    
    // MARK: - Properties
    
    let rooms: [String : RoomState]
    
    static let empty: RoomListState = RoomListState(rooms: [:])
    
    // MARK: - Accessors
    
    let isComplete = true
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: RoomListState) -> RoomListState {
        let rooms = self.rooms.mapValues { (room) -> RoomState in
            if let supplementalRoom = supplementalState.rooms[room.identifier] {
                return room.supplement(withState: supplementalRoom)
            }
            else {
                return room
            }
        }
        
        return RoomListState(rooms: rooms)
    }
    
}

// MARK: - Equatable

extension RoomListState: Equatable {}
