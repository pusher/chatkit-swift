import Foundation

public final class PCUser {
    public let id: String
    public let createdAt: String
    public var updatedAt: String
    public var name: String?
    public var avatarURL: String?
    public var customData: [String: Any]?
    public internal(set) var presenceState: PCPresenceState

    public lazy var pathFriendlyID: String = {
        return pathFriendlyVersion(of: self.id)
    }()

    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }

    public var displayName: String {
        get {
            return self.name ?? self.id
        }
    }

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        name: String?,
        avatarURL: String?,
        customData: [String: Any]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.avatarURL = avatarURL
        self.customData = customData
        self.presenceState = .unknown
    }

    func updatePresenceInfoIfAppropriate(newInfoPayload: PCPresencePayload) {
        if newInfoPayload.state != .unknown {
            self.presenceState = newInfoPayload.state
        }
    }
}

extension PCUser: PCUpdatable {
    @discardableResult
    func updateWithPropertiesOf(_ user: PCUser) -> PCUser {
        self.name = user.name
        self.avatarURL = user.avatarURL
        self.customData = user.customData
        self.updatedAt = user.updatedAt
        if user.presenceState != .unknown {
            self.presenceState = user.presenceState
        }
        return self
    }
}

extension PCUser: Hashable {
    public var hashValue: Int {
        return self.id.hashValue
    }

    public static func ==(lhs: PCUser, rhs: PCUser) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PCUser: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "ID: \(self.id) Name: \(self.name ?? "nil")"
    }
}

extension PCUser {
    func copy() -> PCUser {
        return PCUser(
            id: self.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            name: self.name,
            avatarURL: self.avatarURL,
            customData: self.customData
        )
    }
}
