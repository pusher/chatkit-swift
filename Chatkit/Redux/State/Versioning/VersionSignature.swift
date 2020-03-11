
enum VersionSignature {
    
    case unsigned
    case initialState
    case addedToRoom(roomIdentifier: String)
    case removedFromRoom(roomIdentifier: String)
    case roomUpdated(roomIdentifier: String)
    case roomDeleted(roomIdentifier: String)
    case readStateUpdated(roomIdentifier: String)
    case subscriptionStateUpdated
    
}

// MARK: - Hashable

extension VersionSignature: Hashable {}
