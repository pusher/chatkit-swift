import Foundation

/// A structure representing a message retrieved from the Chatkit web service.
///
/// The content of a message is made up of 1 or more `MessagePart`s. Each part can be of three types, and should be unpacked
/// using a `switch` on the type.
public struct Message {
    /// The unique identifier for the message assigned by the Chatkit service.
    public let identifier: String
    
    /// The user who sent the message.
    public let sender: User
    
    /// The array of `MessagePart`s that represent the contents of the message.
    public let parts: [MessagePart]
    
    /// The array of users who read the message.
    public let readByUsers: [User]
    
    /// The array of users who read the message and did not read any more recent one in the room.
    public let lastReadByUsers: [User]
    
    /// The `Date` at which the message was created.
    public let createdAt: Date
    
    /// The `Date` at which the message was last updated, either by editing, or because it was "soft" deleted (scrubbed of content, but not removed from the feed)
    ///
    /// This will apply *only* to changes to the `sender` and `parts` properties.
    public let updatedAt: Date
    
    /// The `Date` at which the message was deleted.
    public let deletedAt: Date?
    
    // MARK: - Initializers
    
    init(identifier: String, sender: User, parts: [MessagePart], readByUsers: [User], lastReadByUsers: [User], createdAt: Date, updatedAt: Date, deletedAt: Date?) {
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
    }
    
}
