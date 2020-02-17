
class RemovedFromRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.RemovedFromRoom
    
    // MARK: - Initializers
    
    init(event: Wire.Event.RemovedFromRoom) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension RemovedFromRoomAction: Equatable {
    
    static func == (lhs: RemovedFromRoomAction, rhs: RemovedFromRoomAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
