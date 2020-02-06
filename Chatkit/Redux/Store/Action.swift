
enum Action {
    
    // MARK: User subscription events
    
    case receivedInitialState(event: Wire.Event.InitialState)
    case receivedRemovedFromRoom(event: Wire.Event.RemovedFromRoom)
    
    // MARK: Services
    
    case received(user: Wire.User)
    case fetching(userWithIdentifier: String)
    
}

// MARK: - Equatable

extension Action: Equatable {}
