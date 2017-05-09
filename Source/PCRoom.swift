public class PCRoom {
    public let id: Int
    public let name: String
    public let createdByUserId: Int
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public var users: [PCUser]
    public var messages: [PCMessage]

    public var subscription: PCRoomSubscription? = nil

    // TODO: Maybe a last event id received here, a la Feeds?

    public init(
        id: Int,
        name: String,
        createdByUserId: Int,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        users: [PCUser] = [],
        messages: [PCMessage] = []
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
}

public protocol PCRoomDelegate {
    func messageReceived(room: PCRoom, message: PCMessage)
}
