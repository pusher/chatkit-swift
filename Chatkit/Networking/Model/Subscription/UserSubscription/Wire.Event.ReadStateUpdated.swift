import Foundation


extension Wire.Event {
    
    internal struct ReadStateUpdated {
        let readState: Wire.ReadState
    }
    
}

extension Wire.Event.ReadStateUpdated: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case readState = "read_state"

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
