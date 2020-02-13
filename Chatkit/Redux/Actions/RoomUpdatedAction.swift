
struct RoomUpdatedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RoomUpdated

}

// MARK: - Equatable

extension RoomUpdatedAction: Equatable {}
