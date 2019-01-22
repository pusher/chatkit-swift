import Foundation
import PusherPlatform

public final class PCRoom {
    public let id: String
    public internal(set) var name: String
    public private(set) var isPrivate: Bool
    public let createdByUserID: String
    public let createdAt: String
    public internal(set) var updatedAt: String
    public internal(set) var deletedAt: String?
    public internal(set) var customData: [String: Any]?

    public internal(set) var subscription: PCRoomSubscription?
    public internal(set) var userIDs: Set<String>
    var subscriptionPreviouslyEstablished = false

    // TODO: Should each Room instead have access to the user store and then the users
    // property would become a func with a completion handler that queried the user store
    // based on the user ids that are being tracked in the Room objects
    public var users: [PCUser] {
        // TODO: Is this going to be expensive if this is used as a datasource for a
        // tableview, or similar?
        // TODO: This will also not work well if references to users are stored by
        // a customer
        return Array(self.userStore.users).sorted(by: { $0.id > $1.id })
    }

    public internal(set) var userStore: PCRoomUserStore

    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }
    public var deletedAtDate: Date? {
        guard let deletedAt = self.deletedAt else {
            return nil
        }
        return PCDateFormatter.shared.formatString(deletedAt)
    }

    public init(
        id: String,
        name: String,
        isPrivate: Bool,
        createdByUserID: String,
        createdAt: String,
        updatedAt: String,
        customData: [String: Any]? = nil,
        userIDs: Set<String>? = nil,
        deletedAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isPrivate = isPrivate
        self.createdByUserID = createdByUserID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.customData = customData
        self.userIDs = userIDs ?? []
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
            self.isPrivate == room.isPrivate &&
            (
                (self.customData == nil && room.customData == nil) ||
                (self.customData != nil && room.customData != nil &&
                    (self.customData! as NSDictionary).isEqual(to: room.customData!)
                )
            )
    }
}

extension PCRoom: PCUpdatable {
    @discardableResult
    func updateWithPropertiesOf(_ room: PCRoom) -> PCRoom {
        self.name = room.name
        self.isPrivate = room.isPrivate
        self.updatedAt = room.updatedAt
        self.customData = room.customData
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
            isPrivate: self.isPrivate,
            createdByUserID: self.createdByUserID,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
