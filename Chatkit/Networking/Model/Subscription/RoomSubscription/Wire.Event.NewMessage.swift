import Foundation


extension Wire.Event {
    
    internal struct NewMessage {
        let message: Wire.Message
    }
    
}

extension Wire.Event.NewMessage: Equatable {}

extension Wire.Event.NewMessage: Decodable {
    
    init(from decoder: Decoder) throws {
        self.message = try Wire.Message(from: decoder)
    }
}
