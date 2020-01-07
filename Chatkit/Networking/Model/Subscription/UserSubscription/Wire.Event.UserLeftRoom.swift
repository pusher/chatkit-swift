import Foundation


extension Wire.Event {
    
    internal struct UserLeftRoom: Decodable {
        
        let roomIdentifier: String
        let userIdentifier: String
        
        private enum CodingKeys: String, CodingKey {
            case roomIdentifier = "room_id"
            case userIdentifier = "user_id"
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
}
