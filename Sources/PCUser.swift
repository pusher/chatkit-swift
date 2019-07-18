import Foundation

public final class PCUser {
    private let lock = DispatchSemaphore(value: 1)

    // Immutable properties are safe
    public let id: String
    public let createdAt: String

    // Mutable properties must be protected, these should only be referenced in the constructor and guarded setters
    private var _updatedAt: String
    private var _name: String?
    private var _avatarURL: String?
    private var _customData: [String: Any]?
    private var _presenceState: PCPresenceState

    // Guarded getters and setters for mutable properties
    public var updatedAt: String {
        get { return self.lock.synchronized { self._updatedAt } }
        set(v) { self.lock.synchronized { self._updatedAt = v } }
    }

    public var name: String? {
        get { return self.lock.synchronized { self._name } }
        set(v) { self.lock.synchronized { self._name = v } }
    }

    public var avatarURL: String? {
        get { return self.lock.synchronized { self._avatarURL } }
        set(v) { self.lock.synchronized { self._avatarURL = v } }
    }

    public var customData: [String: Any]? {
        get { return self.lock.synchronized { self._customData } }
        set(v) { self.lock.synchronized { self._customData = v } }
    }

    public var presenceState: PCPresenceState {
        get { return self.lock.synchronized { self._presenceState } }
        set(v) { self.lock.synchronized { self._presenceState = v } }
    }

    // True computed properties
    public var pathFriendlyID: String { return pathFriendlyVersion(of: self.id) }
    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }
    public var displayName: String { return self.name ?? self.id }

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
        self._updatedAt = updatedAt
        self._name = name
        self._avatarURL = avatarURL
        self._customData = customData
        self._presenceState = .unknown
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
