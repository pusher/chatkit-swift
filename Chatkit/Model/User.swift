import Foundation
import CoreData

public struct User {
    
    // MARK: - Properties
    
    public let identifier: String
    public let name: String?
    public let avatar: URL?
    public let presenceState: PresenceState
    public let userData: UserData?
    public let createdAt: Date
    public let updatedAt: Date
    
    let objectID: NSManagedObjectID
    
    // MARK: - Initializers
    
    init(identifier: String, name: String?, avatar: URL?, presenceState: PresenceState, userData: UserData?, createdAt: Date, updatedAt: Date, objectID: NSManagedObjectID) {
        self.identifier = identifier
        self.name = name
        self.avatar = avatar
        self.presenceState = presenceState
        self.userData = userData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.objectID = objectID
    }
    
}

// MARK: - Hashable

extension User: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension User: Equatable {
    
    public static func == (lhs: User, rhs: User) -> Bool {
        // User data is intentionally excluded from this comparison.
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.avatar == rhs.avatar
            && lhs.presenceState == rhs.presenceState
            && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
            && lhs.objectID == rhs.objectID
    }
    
}

// MARK: - Model

extension User: Model {
}

// MARK: - Identifiable

extension User: Identifiable {
}
