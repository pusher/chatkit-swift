import Foundation


extension Wire.Event {
    
    internal struct RoomUpdated: Decodable {
        
        let room: Wire.Room
        
    }
    
}
