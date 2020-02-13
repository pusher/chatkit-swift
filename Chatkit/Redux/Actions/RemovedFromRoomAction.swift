
struct RemovedFromRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RemovedFromRoom
    
}

// MARK: - Equatable

extension RemovedFromRoomAction: Equatable {}
