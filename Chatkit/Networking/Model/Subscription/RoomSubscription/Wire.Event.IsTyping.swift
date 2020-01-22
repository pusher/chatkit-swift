import Foundation


extension Wire.Event {
        
    internal struct IsTyping {
        let userIdentifier: String
    }
    
}

extension Wire.Event.IsTyping: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case userIdentifier = "user_id"
        
        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
