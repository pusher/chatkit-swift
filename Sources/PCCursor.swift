import Foundation

public class PCCursor {
    public let type: PCCursorType
    public let position: Int
    public let room: PCRoom
    public let updatedAt: String
    public let user: PCUser

    public var updatedAtDate: Date { return self.dateFormatter.date(from: self.updatedAt)! }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    init(
        type: PCCursorType,
        position: Int,
        room: PCRoom,
        updatedAt: String,
        user: PCUser
    ) {
        self.type = type
        self.position = position
        self.room = room
        self.updatedAt = updatedAt
        self.user = user
    }
}

extension PCCursor: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Type: \(type.debugDescription), Position: \(position), Room: \(room.id), User: \(user.id), Updated At: \(updatedAt)"
    }
}
