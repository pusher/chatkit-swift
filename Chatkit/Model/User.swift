import Foundation

public struct User {
    
    // MARK: - Properties
    
    public let identifier: String
    public let name: String?
    public let avatar: URL?
    public let presenceState: PresenceState
    public let metadata: Metadata?
    public let createdAt: Date
    public let updatedAt: Date
    
    // MARK: - Initializers
    
    init(identifier: String, name: String?, avatar: URL?, presenceState: PresenceState, metadata: Metadata?, createdAt: Date, updatedAt: Date) {
        self.identifier = identifier
        self.name = name
        self.avatar = avatar
        self.presenceState = presenceState
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}

// MARK: - Model

extension User: Model {
}
