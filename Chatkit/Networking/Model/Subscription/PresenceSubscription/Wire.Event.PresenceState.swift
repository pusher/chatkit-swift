import Foundation


extension Wire.Event {
    
    internal enum PresenceState: String, Decodable {
        case online
        case offline
        
        private enum CodingKeys: String, CodingKey {
            case state
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawValue = try container.decode(String.self, forKey: .state)
            guard let presenceState = PresenceState(rawValue: rawValue) else {
                let desc = "Cannot initialize \(PresenceState.self) from invalid string value \"\(rawValue)\""
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.state, in: container, debugDescription: desc)
            }
            self = presenceState
        }
    }
}
