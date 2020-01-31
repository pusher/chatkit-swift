import Foundation


extension Wire {
    
    internal struct Message {
        
        let identifier: Int64
        let userIdentifier: String
        let roomIdentifier: String
        let parts: [Wire.MessagePart]
        let createdAt: Date
        let updatedAt: Date
    }
    
}

extension Wire.Message: Equatable {}

extension Wire.Message: Decodable {
    
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
