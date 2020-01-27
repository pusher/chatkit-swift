import Foundation

extension Wire {

    internal struct ReadState {
        let roomIdentifier: String
        let unreadCount: UInt64
        let cursor: Cursor
    }

}

extension Wire.ReadState: Equatable {}

extension Wire.ReadState: Decodable {

    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case unreadCount = "unread_count"
        case cursor

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
