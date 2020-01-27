import Foundation

/// A structure representing a user retrieved from the Chatkit web service.
public struct User {
    
    // MARK: - Properties
    
    /// The unique identifier for the user.
    public let identifier: String
    
    /// The human readable name of the user. This is not required to be unique.
    public let name: String?
    
    /// The location represented as an `URL` of an avatar for the user.
    public let avatar: URL?
    
    /// The current presence state of the user.
    public let presenceState: PresenceState
    
    /// The dictionary of arbitrary data which you may attach to the user.
    public let customData: CustomData?
    
    /// The `Date` at which the user was created.
    public let createdAt: Date
    
    /// The `Date` at which the user entity was last updated by an explicit call to `updateUser` on the Chatkit service.
    ///
    /// This will *only* apply to changes to the `name`, `avatar` and `customData` properties.
    public let updatedAt: Date
    
    // MARK: - Initializers
    
    init(identifier: String, name: String?, avatar: URL?, presenceState: PresenceState, customData: CustomData?, createdAt: Date, updatedAt: Date) {
        self.identifier = identifier
        self.name = name
        self.avatar = avatar
        self.presenceState = presenceState
        self.customData = customData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}

// MARK: - Hashable

extension User: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameters:
    ///     - hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
}

// MARK: - Equatable

extension User: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
    public static func == (lhs: User, rhs: User) -> Bool {
        // User data is intentionally excluded from this comparison.
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.avatar == rhs.avatar
            && lhs.presenceState == rhs.presenceState
            && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
    }
    
}
