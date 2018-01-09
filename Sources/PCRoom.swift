import Foundation
import PusherPlatform

public final class PCRoom {
    public let id: Int
    public internal(set) var name: String
    public private(set) var isPrivate: Bool
    public let createdByUserId: String
    public let createdAt: String
    public internal(set) var updatedAt: String
    public internal(set) var deletedAt: String?

    public internal(set) var subscription: PCRoomSubscription?

    public internal(set) var userIds: Set<String>

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

    public init(
        id: Int,
        name: String,
        isPrivate: Bool,
        createdByUserId: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        userIds: Set<String>? = nil
    ) {
        self.id = id
        self.name = name
        self.isPrivate = isPrivate
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.userIds = userIds ?? []
        self.userStore = PCRoomUserStore()
    }

    func updateWithPropertiesOfRoom(_ room: PCRoom) {
        self.name = room.name
        self.isPrivate = room.isPrivate
        self.updatedAt = room.updatedAt
        self.deletedAt = room.deletedAt
        self.userIds = room.userIds
    }
}

extension PCRoom: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func ==(_ lhs: PCRoom, _ rhs: PCRoom) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PCRoom: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "ID: \(self.id) Name: \(self.name) Private: \(self.isPrivate)"
    }
}
