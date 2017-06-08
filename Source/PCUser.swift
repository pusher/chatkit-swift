import Foundation

public class PCUser {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customData: [String: Any]?
    public internal(set) var presenceState: PCPresenceState
    public internal(set) var lastSeenAt: String?

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customData: [String: Any]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customData = customData
        self.presenceState = .unknown
        self.lastSeenAt = nil
    }


    // TODO: Could use inout?
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
        return self.id.hashValue
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
