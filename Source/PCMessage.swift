public struct PCMessage {
    public let id: Int
    public let senderId: Int
    public let roomId: Int
    public internal(set) var text: String
    public let createdAt: String
    public let updatedAt: String

    // TODO: How do we make it easy to get info about the linked entities?
    // i.e. make it easy to get the room and user (sender) from a message?
    // ChatManager strikes again...maybe?

    //    public let sender: PCUser

    public init(
        id: Int,
        senderId: Int,
        roomId: Int,
        text: String,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.senderId = senderId
        self.roomId = roomId
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
