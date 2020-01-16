import Foundation


extension Wire.Event {
    
    internal struct RoomDeleted {
        let roomIdentifier: String
    }
    
}

extension Wire.Event.RoomDeleted: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
