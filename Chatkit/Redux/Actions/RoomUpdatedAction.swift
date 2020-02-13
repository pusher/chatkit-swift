
class RoomUpdatedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RoomUpdated
    
    // MARK: - Initializers
    
    init(event: Wire.Event.RoomUpdated) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension RoomUpdatedAction: Equatable {
    
    static func == (lhs: RoomUpdatedAction, rhs: RoomUpdatedAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
