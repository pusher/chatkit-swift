import Foundation


extension Wire.Event {
    
    internal struct RoomDeleted: Decodable {
        
        let roomIdentifier: String
        
        private enum CodingKeys: String, CodingKey {
            case roomIdentifier = "room_id"
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
}
