import Foundation


extension Wire.Event {
    
    internal struct RemovedFromRoom {
        let roomIdentifier: String
    }
    
}

extension Wire.Event.RemovedFromRoom: Equatable {}

extension Wire.Event.RemovedFromRoom: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
