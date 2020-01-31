import Foundation

extension Wire {
    
    internal struct Cursor {
        let roomIdentifier: String
        let userIdentifier: String
        let cursorType: Wire.CursorType
        let position: Int64
        let updatedAt: Date
    }
    
}

extension Wire.Cursor: Equatable {}

extension Wire.Cursor: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case userIdentifier = "user_id"
        case cursorType = "cursor_type"
        case position
        case updatedAt = "updated_at"

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
