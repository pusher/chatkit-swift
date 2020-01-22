import Foundation


extension Wire.Event {
    
    internal struct MessageDeleted {
        let messageIdentifier: String
    }
    
}

extension Wire.Event.MessageDeleted: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case messageIdentifier = "message_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
