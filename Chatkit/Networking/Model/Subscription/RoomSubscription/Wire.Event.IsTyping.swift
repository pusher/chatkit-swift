import Foundation


extension Wire.Event {
        
    internal struct IsTyping: Decodable {
        
        let userIdentifier: String
        
        private enum CodingKeys: String, CodingKey {
            case userIdentifier = "user_id"
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
}
