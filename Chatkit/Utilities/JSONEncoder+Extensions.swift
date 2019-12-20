import Foundation

internal extension JSONEncoder {
    
    // MARK: - Properties
    
    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
}
