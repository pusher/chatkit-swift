
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
    case addedToRoom
    case removedFromRoom
    case roomUpdated
    case roomDeleted
    case readStateUpdated
    
}
