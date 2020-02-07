
struct ReceivedInitialStateAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.InitialState
    
}

// MARK: - Equatable

extension ReceivedInitialStateAction: Equatable {}
