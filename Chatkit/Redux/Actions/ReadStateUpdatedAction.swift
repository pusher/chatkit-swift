
struct ReadStateUpdatedAction: Action {
    
    // MARK: - Properties
    
    let event: Wire.Event.ReadStateUpdated
    
}

// MARK: - Equatable

extension ReadStateUpdatedAction: Equatable {}
