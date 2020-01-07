import Foundation


extension Wire.Event {
    
    internal struct ReadStateUpdated: Decodable {
        
        let readState: Wire.ReadState
        
        private enum CodingKeys: String, CodingKey {
            case readState = "read_state"

            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
}
