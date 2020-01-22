import Foundation


extension Wire.Event {
    
    internal struct AddedToRoom {
        
        let room: Wire.Room
        let membership: Wire.Membership
        let readState: Wire.ReadState
    }
    
}

extension Wire.Event.AddedToRoom: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case room
        case membership
        case readState = "read_state"

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
