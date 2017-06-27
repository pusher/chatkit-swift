import Foundation

public final class PCMessage {
    public let id: Int
    public let text: String
    public let createdAt: String
    public let updatedAt: String
    public let sender: PCUser
    public let room: PCRoom

    public init(
        id: Int,
        text: String,
        createdAt: String,
        updatedAt: String,
        sender: PCUser,
        room: PCRoom
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sender = sender
        self.room = room
    }
}

extension PCMessage: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func ==(_ lhs: PCMessage, _ rhs: PCMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
