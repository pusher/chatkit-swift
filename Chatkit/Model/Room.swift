import Foundation
import CoreData

public struct Room {
    
    // MARK: - Properties
    
    public let identifier: String
    public let name: String?
    public let isPrivate: Bool
    public let creator: User?
    public let members: [User]
    public let typingMembers: [User]
    public let unreadCount: UInt64
    public let lastMessage: Message?
    public let userData: UserData?
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    
    let objectID: NSManagedObjectID
    
    // MARK: - Initializers
    
    init(identifier: String, name: String?, isPrivate: Bool, creator: User?, members: [User], typingMembers: [User], unreadCount: UInt64, lastMessage: Message?, userData: UserData?, createdAt: Date, updatedAt: Date, deletedAt: Date?, objectID: NSManagedObjectID) {
        self.identifier = identifier
        self.name = name
        self.isPrivate = isPrivate
        self.creator = creator
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension Room: Equatable {
    
    public static func == (lhs: Room, rhs: Room) -> Bool {
        // User data is intentionally excluded from this comparison.
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.isPrivate == rhs.isPrivate
            && lhs.creator == rhs.creator
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
