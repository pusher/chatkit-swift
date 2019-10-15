import Foundation
import CoreData

/// A structure representing a room retrieved from the Chatkit web service.
public struct Room {
    
    // MARK: - Properties
    
    /// The unique identifier for the room assigned by the Chatkit web service.
    public let identifier: String
    
    /// The human readable name of the room. This is not required to be unique.
    public let name: String?
    
    /// A boolean value that determines whether or not the room is private.
    public let isPrivate: Bool
    
    /// The array of users on the room.
    public let members: [User]
    
    /// The array of users currently typing on the room.
    public let typingMembers: [User]
    
    /// The number of unread messages for the given user in this room.
    ///
    /// The value of this property is only defined if the user is a member of the room.
    public let unreadCount: UInt64
    
    /// The last message sent in this room.
    ///
    /// The value of this property is only defined if the user is a member of the room and the room has messages.
    public let lastMessage: Message?
    
    /// The dictionary of arbitrary data which you may attach to the room.
    public let userData: UserData?
    
    /// The `Date` at which the room was created.
    public let createdAt: Date
    
    /// The `Date` at which the room was last updated.
    public let updatedAt: Date
    
    /// The `Date` at which the room was deleted.
    public let deletedAt: Date?
    
    let objectID: NSManagedObjectID
    
    // MARK: - Initializers
    
    init(identifier: String, name: String?, isPrivate: Bool, members: [User], typingMembers: [User], unreadCount: UInt64, lastMessage: Message?, userData: UserData?, createdAt: Date, updatedAt: Date, deletedAt: Date?, objectID: NSManagedObjectID) {
        self.identifier = identifier
        self.name = name
        self.isPrivate = isPrivate
        self.members = members
        self.typingMembers = typingMembers
        self.unreadCount = unreadCount
        self.lastMessage = lastMessage
        self.userData = userData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.objectID = objectID
    }
    
}

// MARK: - Hashable

extension Room: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameters:
    ///     - hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension Room: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
    public static func == (lhs: Room, rhs: Room) -> Bool {
        // User data is intentionally excluded from this comparison.
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.isPrivate == rhs.isPrivate
            && lhs.members == rhs.members
            && lhs.typingMembers == rhs.typingMembers
            && lhs.unreadCount == rhs.unreadCount
            && lhs.lastMessage == rhs.lastMessage
            && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
            && lhs.deletedAt == rhs.deletedAt
            && lhs.objectID == rhs.objectID
    }
    
}

// MARK: - Model

extension Room: Model {
}

// MARK: - Identifiable

extension Room: Identifiable {
}
