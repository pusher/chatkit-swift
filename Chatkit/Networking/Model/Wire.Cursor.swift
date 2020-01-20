import Foundation

extension Wire {
    
    internal struct Cursor {
        let roomIdentifier: String
        let userIdentifier: String
        let cursorType: CursorType
        let position: Int64
    }
    
}

extension Wire.Cursor: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case userIdentifier = "user_id"
        case cursorType = "type"
        case position

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}

