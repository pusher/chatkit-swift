import PusherPlatform

public class PCRoom {
    public let id: Int
    public var name: String
    public let createdByUserId: Int
    public let createdAt: String
    public var updatedAt: String
    public var deletedAt: String?
    public var users: PCSynchronizedArray<PCUser>
    public var messages: PCSynchronizedArray<PCMessage>

    public var subscription: PCRoomSubscription? = nil

    // TODO: Maybe a last event id received here, a la Feeds?

    public init(
        id: Int,
        name: String,
        createdByUserId: Int,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        users: PCSynchronizedArray<PCUser> = PCSynchronizedArray<PCUser>(),
        messages: PCSynchronizedArray<PCMessage> = PCSynchronizedArray<PCMessage>()
    ) {
        self.id = id
        self.name = name
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.users = users
        self.messages = messages
    }

    internal func updateWithPropertiesOfRoom(_ room: PCRoom) {
        self.name = room.name
        self.updatedAt = room.updatedAt
        self.deletedAt = room.deletedAt
    }
}
