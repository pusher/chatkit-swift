public class PCUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?
    public internal(set) var presenceState: PCPresenceState
    public internal(set) var lastSeenAt: String?

    public init(
        id: Int,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customId: String? = nil,
        customData: [String: Any]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customId = customId
        self.customData = customData
        self.presenceState = .unknown
        self.lastSeenAt = nil
    }

    func updateWithPropertiesOfUser(_ user: PCUser) -> PCUser {
        if self.presenceState != .unknown {
            self.presenceState = user.presenceState
            self.lastSeenAt = user.lastSeenAt
        }

        return self
    }
}

extension PCUser: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func ==(_ lhs: PCUser, _ rhs: PCUser) -> Bool {
        return lhs.id == rhs.id
    }

}

extension PCUser: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "ID: \(self.id) Name: \(self.name ?? "nil")"
    }

}
