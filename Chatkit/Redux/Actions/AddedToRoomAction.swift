
struct AddedToRoomAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.AddedToRoom
    
}

// MARK: - Equatable

extension AddedToRoomAction: Equatable  {}
