import Foundation

public struct Message {
    
    public let identifier: String
    public let sender: User
    public let parts: Set<MessagePart>
    public let readByUsers: Set<User>?
    public let lastReadByUsers: Set<User>?
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    
    // MARK: - Initializers
    
    init(identifier: String, sender: User, parts: Set<MessagePart>, readByUsers: Set<User>?, lastReadByUsers: Set<User>?, createdAt: Date, updatedAt: Date, deletedAt: Date?) {
        self.identifier = identifier
        self.sender = sender
        self.parts = parts
        self.readByUsers = readByUsers
        self.lastReadByUsers = lastReadByUsers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
}

// MARK: - Hashable

extension Message: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension Message: Equatable {
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.sender == rhs.sender && lhs.parts == rhs.parts && lhs.readByUsers == rhs.readByUsers && lhs.lastReadByUsers == rhs.lastReadByUsers && lhs.createdAt == rhs.createdAt && lhs.updatedAt == rhs.updatedAt && lhs.deletedAt == rhs.deletedAt
    }
    
}

// MARK: - Model

extension Message: Model {
}
