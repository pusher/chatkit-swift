
class ReceivedInitialStateAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.InitialState
    
    // MARK: - Initializers
    
    init(event: Wire.Event.InitialState) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension ReceivedInitialStateAction: Equatable {
    
    static func == (lhs: ReceivedInitialStateAction, rhs: ReceivedInitialStateAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
