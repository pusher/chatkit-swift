import Foundation

public final class PCMessage: PCEnrichedMessage {
    public let id: Int
    public let text: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let attachment: PCAttachment?
    public let sender: PCUser
    public let room: PCRoom

    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }
    public var deletedAtDate: Date? {
        guard let deletedAt = self.deletedAt else {
            return nil
        }
        return PCDateFormatter.shared.formatString(deletedAt)
    }

    public init(
        id: Int,
        text: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        attachment: PCAttachment?,
        sender: PCUser,
        room: PCRoom
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.attachment = attachment
        self.sender = sender
        self.room = room
    }
}

extension PCMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Message - ID: \(self.id), sender: \(self.sender.id), text: \(self.text), hasAttachment: \(self.attachment != nil)"
    }
}

extension PCMessage: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func ==(lhs: PCMessage, rhs: PCMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
