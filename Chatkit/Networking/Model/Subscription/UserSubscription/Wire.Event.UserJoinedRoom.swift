import Foundation


extension Wire.Event {
    
    internal struct UserJoinedRoom {
        let roomIdentifier: String
        let userIdentifier: String
    }
    
}

extension Wire.Event.UserJoinedRoom: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case userIdentifier = "user_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
