import Foundation


extension Wire {
    
    internal struct Message: Decodable {
        
        let identifier: Int64
        let userIdentifier: String
        let roomIdentifier: String
        let parts: [MessagePart]
        let createdAt: Date
        let updatedAt: Date
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case userIdentifier = "user_id"
            case roomIdentifier = "room_id"
            case parts
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
}
