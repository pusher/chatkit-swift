import Foundation

internal extension JSONDecoder {
    
    // MARK: - Properties
    
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
}
