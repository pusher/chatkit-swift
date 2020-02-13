
struct RoomDeletedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RoomDeleted
    
}

// MARK: - Equatable

extension RoomDeletedAction: Equatable {}
