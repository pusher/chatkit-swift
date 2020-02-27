
protocol Versionable {
    
    // MARK: - Types
    
    typealias Version = UInt64
    
    // MARK: - Properties
    
    var version: Version { get }
    var signature: VersionSignature { get }
    
}

// MARK: - Signature

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

extension VersionSignature: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .unsigned:
            hasher.combine(0) // Discriminator
            
        case .initialState:
            hasher.combine(1) // Discriminator
            
        case let .addedToRoom(roomIdentifier):
            hasher.combine(2) // Discriminator
            hasher.combine(roomIdentifier)
            
        case let .removedFromRoom(roomIdentifier):
            hasher.combine(3) // Discriminator
            hasher.combine(roomIdentifier)
            
        case let .roomUpdated(roomIdentifier):
            hasher.combine(4) // Discriminator
            hasher.combine(roomIdentifier)
            
        case let .roomDeleted(roomIdentifier):
            hasher.combine(5) // Discriminator
            hasher.combine(roomIdentifier)
            
        case let .readStateUpdated(roomIdentifier):
            hasher.combine(6) // Discriminator
            hasher.combine(roomIdentifier)
            
        case .subscriptionStateUpdated:
            hasher.combine(7) // Discriminator
        }
    }
    
}
