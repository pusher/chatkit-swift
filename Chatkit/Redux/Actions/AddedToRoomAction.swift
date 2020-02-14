
class AddedToRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.AddedToRoom
    
    // MARK: - Initializers
    
    init(event: Wire.Event.AddedToRoom) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension AddedToRoomAction: Equatable {
    
    static func == (lhs: AddedToRoomAction, rhs: AddedToRoomAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
