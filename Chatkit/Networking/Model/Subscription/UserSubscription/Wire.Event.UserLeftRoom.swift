import Foundation


extension Wire.Event {
    
    internal struct UserLeftRoom {
        let roomIdentifier: String
        let userIdentifier: String
    }
    
}

extension Wire.Event.UserLeftRoom: Equatable {}

extension Wire.Event.UserLeftRoom: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case userIdentifier = "user_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
