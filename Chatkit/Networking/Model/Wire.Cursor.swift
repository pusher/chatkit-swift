import Foundation

extension Wire {

    internal struct Cursor: Decodable {
        
        let roomIdentifier: String
        let userIdentifier: String
        let cursorType: CursorType
        let position: Int64
        let updatedAt: Date
        
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

}

