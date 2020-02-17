
class InitialStateAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.InitialState
    
    // MARK: - Initializers
    
    init(event: Wire.Event.InitialState) {
        self.event = event
    }
    
}

// MARK: - Equatable

extension InitialStateAction: Equatable {
    
    static func == (lhs: InitialStateAction, rhs: InitialStateAction) -> Bool {
        return lhs.event == rhs.event
    }
    
}
