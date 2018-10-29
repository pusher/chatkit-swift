import Foundation

public final class PCUser {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public var avatarURL: String?
    public let customData: [String: Any]?
    public internal(set) var presenceState: PCPresenceState

    public lazy var pathFriendlyID: String = {
        return pathFriendlyVersion(of: self.id)
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    public var createdAtDate: Date { return self.dateFormatter.date(from: self.createdAt)! }
    public var updatedAtDate: Date { return self.dateFormatter.date(from: self.updatedAt)! }

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

    // TODO: Could use inout?
    func updateWithPropertiesOfUser(_ user: PCUser) -> PCUser {
        if user.presenceState != .unknown {
            self.presenceState = user.presenceState
        }

        return self
    }

    func updatePresenceInfoIfAppropriate(newInfoPayload: PCPresencePayload) {
        if newInfoPayload.state != .unknown {
            self.presenceState = newInfoPayload.state
        }
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
