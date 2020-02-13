
struct InitialStateAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.InitialState
    
}

// MARK: - Equatable

extension InitialStateAction: Equatable {}
