import Foundation

public final class PCMessage {
    public let id: Int
    public let text: String
    public let createdAt: String
    public let updatedAt: String
    public let attachment: PCAttachment?
    public let sender: PCUser
    public let room: PCRoom

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    public var createdAtDate: Date { return self.dateFormatter.date(from: self.createdAt)! }
    public var updatedAtDate: Date { return self.dateFormatter.date(from: self.updatedAt)! }

    public init(
        id: Int,
        text: String,
        createdAt: String,
        updatedAt: String,
        attachment: PCAttachment?,
        sender: PCUser,
        room: PCRoom
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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

    public static func ==(_ lhs: PCMessage, _ rhs: PCMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
