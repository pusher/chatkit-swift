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
}
