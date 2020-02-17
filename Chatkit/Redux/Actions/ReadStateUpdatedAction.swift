
class ReadStateUpdatedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.ReadStateUpdated
    
    // MARK: - Initializers
    
    init(event: Wire.Event.ReadStateUpdated) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension ReadStateUpdatedAction: Equatable {
    
    static func == (lhs: ReadStateUpdatedAction, rhs: ReadStateUpdatedAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
