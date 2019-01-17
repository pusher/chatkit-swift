import Foundation

public class PCCursor {
    public let type: PCCursorType
    public let position: Int
    public let room: PCRoom
    public let updatedAt: String
    public let user: PCUser

    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }

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

    public func equalBarPositionTo(_ cursor: PCCursor) -> Bool {
        return
            self.type == cursor.type &&
            self.room == cursor.room &&
            self.user == cursor.user
    }
}

extension PCCursor: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Type: \(type.debugDescription), Position: \(position), Room: \(room.id), User: \(user.id), Updated At: \(updatedAt)"
    }
}

extension PCCursor: Hashable {
    public var hashValue: Int {
        return self.type.hashValue ^ self.room.hashValue ^ self.user.hashValue
    }

    public static func ==(lhs: PCCursor, rhs: PCCursor) -> Bool {
        return
            lhs.type == rhs.type &&
            lhs.room == rhs.room &&
            lhs.user == rhs.user
    }
}

extension PCCursor {
    func copy() -> PCCursor {
        return PCCursor(
            type: self.type,
            position: self.position,
            room: self.room,
            updatedAt: self.updatedAt,
            user: self.user
        )
    }
}
