import Foundation
import CoreData

/// A structure representing a message retrieved from the Chatkit web service.
public struct Message {
    
    /// The unique identifier for the message assigned by the Chatkit web service.
    public let identifier: String
    
    /// The user who sent the message.
    public let sender: User
    
    /// The array of `MessagePart` that represents the contents of the message.
    public let parts: [MessagePart]
    
    /// The array of users who read the message.
    public let readByUsers: [User]
    
    /// The array of users who read the message and did not read any more recent one in the room.
    public let lastReadByUsers: [User]
    
    /// The `Date` at which the message was created.
    public let createdAt: Date
    
    /// The `Date` at which the message was last updated.
    public let updatedAt: Date
    
    /// The `Date` at which the message was deleted.
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
    
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameters:
    ///     - hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension Message: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
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
