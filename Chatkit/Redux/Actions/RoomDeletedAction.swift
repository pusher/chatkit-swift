
class RoomDeletedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RoomDeleted
    
    // MARK: - Initializers
    
    init(event: Wire.Event.RoomDeleted) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension RoomDeletedAction: Equatable {
    
    static func == (lhs: RoomDeletedAction, rhs: RoomDeletedAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
