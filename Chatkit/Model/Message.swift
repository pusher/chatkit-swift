import Foundation
import CoreData

public struct Message {
    
    public let identifier: String
    public let sender: User
    public let parts: [MessagePart]
    public let readByUsers: [User]
    public let lastReadByUsers: [User]
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    
    let objectID: NSManagedObjectID
    
    // MARK: - Initializers
    
    init(identifier: String, sender: User, parts: [MessagePart], readByUsers: [User], lastReadByUsers: [User], createdAt: Date, updatedAt: Date, deletedAt: Date?, objectID: NSManagedObjectID) {
        self.identifier = identifier
        self.sender = sender
        self.parts = parts
        self.readByUsers = readByUsers
        self.lastReadByUsers = lastReadByUsers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.objectID = objectID
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
        return lhs.identifier == rhs.identifier
            && lhs.sender == rhs.sender
            && lhs.parts == rhs.parts
            && lhs.readByUsers == rhs.readByUsers
            && lhs.lastReadByUsers == rhs.lastReadByUsers
            && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
            && lhs.deletedAt == rhs.deletedAt
            && lhs.objectID == rhs.objectID
    }
    
}

// MARK: - Model

extension Message: Model {
}

// MARK: - Identifiable

extension Message: Identifiable {
}
