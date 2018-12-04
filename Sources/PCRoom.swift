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

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    public var createdAtDate: Date { return self.dateFormatter.date(from: self.createdAt)! }
    public var updatedAtDate: Date { return self.dateFormatter.date(from: self.updatedAt)! }
    public var deletedAtDate: Date? {
        guard let deletedAt = self.deletedAt else {
            return nil
        }
        return self.dateFormatter.date(from: deletedAt)!
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

    func updateWithPropertiesOfRoom(_ room: PCRoom) {
        self.name = room.name
        self.isPrivate = room.isPrivate
        self.updatedAt = room.updatedAt
        self.customData = room.customData
        self.userIDs = room.userIDs
        self.deletedAt = room.deletedAt
    }
}

extension PCRoom: Hashable {
    public var hashValue: Int {
        return self.id.hashValue
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
