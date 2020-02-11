
class ReceivedRemovedFromRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RemovedFromRoom
    
    // MARK: - Initializers
    
    init(event: Wire.Event.RemovedFromRoom) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension ReceivedRemovedFromRoomAction: Equatable {
    
    static func == (lhs: ReceivedRemovedFromRoomAction, rhs: ReceivedRemovedFromRoomAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
