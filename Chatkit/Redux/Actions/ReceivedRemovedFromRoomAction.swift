
struct ReceivedRemovedFromRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RemovedFromRoom
    
}

// MARK: - Equatable

extension ReceivedRemovedFromRoomAction: Equatable {}
