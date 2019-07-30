import Foundation
import PusherPlatform

public final class PCRoom {
    private let lock = DispatchSemaphore(value: 1)

    // Immutable properies are safe to be public
    public let id: String
    public let createdByUserID: String
    public let createdAt: String

    // Mutable properties must be protected, these should only be referenced in the constructor and guarded setters
    private var _name: String
    private var _pushNotificationTitleOverride: String?
    private var _isPrivate: Bool
    private var _updatedAt: String
    private var _deletedAt: String?
    private var _customData: [String: Any]?
    private var _unreadCount: Int?
    private var _lastMessageAt: String?

    private var _subscription: PCRoomSubscription?
    private var _userIDs: Set<String>
    private var _subscriptionPreviouslyEstablished = false

    public private(set) var userStore: PCRoomUserStore

    // Guarded getters and setters for mutable properties
    public private(set) var name: String {
        get { return self.lock.synchronized { self._name } }
        set(v) { self.lock.synchronized { self._name = v } }
    }

    public private(set) var pushNotificationTitleOverride: String? {
        get { return self.lock.synchronized { self._pushNotificationTitleOverride } }
        set(v) { self.lock.synchronized { self._pushNotificationTitleOverride = v } }
    }

    public private(set) var isPrivate: Bool {
        get { return self.lock.synchronized { self._isPrivate } }
        set(v) { self.lock.synchronized { self._isPrivate = v } }
    }

    public private(set) var updatedAt: String {
        get { return self.lock.synchronized { self._updatedAt } }
        set(v) { self.lock.synchronized { self._updatedAt = v } }
    }

    public private(set) var deletedAt: String? {
        get { return self.lock.synchronized { self._deletedAt } }
        set(v) { self.lock.synchronized { self._deletedAt = v } }
    }

    public private(set) var customData: [String: Any]? {
        get { return self.lock.synchronized { self._customData } }
        set(v) { self.lock.synchronized { self._customData = v } }
    }

    public private(set) var unreadCount: Int? {
        get { return self.lock.synchronized { self._unreadCount } }
        set(v) { self.lock.synchronized { self._unreadCount = v } }
    }

    public private(set) var lastMessageAt: String? {
        get { return self.lock.synchronized { self._lastMessageAt } }
        set(v) { self.lock.synchronized { self._lastMessageAt = v } }
    }

    public internal(set) var subscription: PCRoomSubscription? {
        get { return self.lock.synchronized { self._subscription } }
        set(v) { self.lock.synchronized { self._subscription = v } }
    }

    public internal(set) var userIDs: Set<String> {
        get { return self.lock.synchronized { self._userIDs } }
        set(v) { self.lock.synchronized { self._userIDs = v } }
    }

    internal var subscriptionPreviouslyEstablished: Bool {
        get { return self.lock.synchronized { self._subscriptionPreviouslyEstablished } }
        set(v) { self.lock.synchronized { self._subscriptionPreviouslyEstablished = v } }
    }

    // True computed properties
    public var users: [PCUser] {
        return Array(self.userStore.users).sorted(by: { $0.id > $1.id })
    }

    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }
    public var deletedAtDate: Date? {
        guard let deletedAt = self.deletedAt else {
            return nil
        }
        return PCDateFormatter.shared.formatString(deletedAt)
    }
    public var lastMessageAtDate: Date? {
        guard let lastMessageAt = self.lastMessageAt else {
            return nil
        }
        return PCDateFormatter.shared.formatString(lastMessageAt)
    }

    public init(
        id: String,
        name: String,
        pushNotificationTitleOverride: String? = nil,
        isPrivate: Bool,
        createdByUserID: String,
        createdAt: String,
        updatedAt: String,
        customData: [String: Any]? = nil,
        unreadCount: Int? = nil,
        lastMessageAt: String? = nil,
        userIDs: Set<String>? = nil,
        deletedAt: String? = nil
    ) {
        self.id = id
        self.createdByUserID = createdByUserID
        self.createdAt = createdAt
        self._name = name
        self._pushNotificationTitleOverride = pushNotificationTitleOverride
        self._isPrivate = isPrivate
        self._updatedAt = updatedAt
        self._deletedAt = deletedAt
        self._customData = customData
        self._unreadCount = unreadCount
        self._lastMessageAt = lastMessageAt
        self._userIDs = userIDs ?? []

        self.userStore = PCRoomUserStore()
    }

    public func unsubscribe() {
        self.subscription?.end()
        self.subscription = nil
    }

    func removeUser(id: String) {
        let roomUserIDIndex = userIDs.index(of: id)

        if let indexToRemove = roomUserIDIndex {
            userIDs.remove(at: indexToRemove)
        }

        userStore.remove(id: id)
    }

    func deepEqual(to room: PCRoom) -> Bool {
        return
            self.name == room.name &&
            self.pushNotificationTitleOverride == room.pushNotificationTitleOverride &&
            self.isPrivate == room.isPrivate &&
            (
                (self.customData == nil && room.customData == nil) ||
                (self.customData != nil && room.customData != nil &&
                    (self.customData! as NSDictionary).isEqual(to: room.customData!)
                )
            ) &&
            (self.unreadCount == room.unreadCount) &&
            (self.lastMessageAt == room.lastMessageAt)
    }
}

extension PCRoom: PCUpdatable {
    @discardableResult
    func updateWithPropertiesOf(_ room: PCRoom) -> PCRoom {
        self.name = room.name
        self.pushNotificationTitleOverride = room.pushNotificationTitleOverride
        self.isPrivate = room.isPrivate
        self.updatedAt = room.updatedAt
        self.customData = room.customData
        self.unreadCount = room.unreadCount
        self.lastMessageAt = room.lastMessageAt
        self.userIDs = room.userIDs
        self.deletedAt = room.deletedAt
        return self
    }
}

extension PCRoom: Hashable {
    public var hashValue: Int {
        return self.id.hashValue
    }

    public static func ==(lhs: PCRoom, rhs: PCRoom) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PCRoom: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "ID: \(self.id) Name: \(self.name) Private: \(self.isPrivate)"
    }
}

extension PCRoom {
    func copy() -> PCRoom {
        return PCRoom(
            id: self.id,
            name: self.name,
            pushNotificationTitleOverride: self.pushNotificationTitleOverride,
            isPrivate: self.isPrivate,
            createdByUserID: self.createdByUserID,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
