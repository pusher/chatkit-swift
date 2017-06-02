import PusherPlatform

public class PCRoom {
    public let id: Int
    public internal(set) var name: String
    public let createdByUserId: String
    public let createdAt: String
    public internal(set) var updatedAt: String
    public internal(set) var deletedAt: String?

    public internal(set) var subscription: PCRoomSubscription? = nil

    // TODO: This should be a Set
    // TODO: Do we need both userIds and users? Probably
    public internal(set) var userIds: [String]

    // TODO: Should each Room instead have access to the user store and then the users
    // property would become a func with a completion handler that queried the user store
    // based on the user ids that are being tracked in the Room objects
    public internal(set) var users: Set<PCUser> = []

    public internal(set) var userStore: PCRoomUserStore

    public init(
        id: Int,
        name: String,
        createdByUserId: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        userIds: [String] = []
    ) {
        self.id = id
        self.name = name
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.userIds = userIds
        self.userStore = PCRoomUserStore()
    }

    func updateWithPropertiesOfRoom(_ room: PCRoom) {
        self.name = room.name
        self.updatedAt = room.updatedAt
        self.deletedAt = room.deletedAt
    }
}
