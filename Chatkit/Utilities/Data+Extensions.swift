import Foundation

internal extension Data {
    
    func jsonDecoder() throws -> Decoder {
        return try JSONDecoder.default.decode(DecoderWrapper.self, from: self).decoder
    }
    
}
