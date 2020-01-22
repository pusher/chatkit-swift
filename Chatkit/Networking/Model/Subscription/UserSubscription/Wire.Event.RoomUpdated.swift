import Foundation


extension Wire.Event {
    
    internal struct RoomUpdated {
        let room: Wire.Room
    }
    
}

extension Wire.Event.RoomUpdated: Decodable {}
