import Foundation

struct MetadataParser {
    
    // MARK: - Public methods
    
    static func deserialize(data: Data?) throws -> Metadata? {
        guard let data = data else {
            return nil
        }
        
        do {
            let metadata = try JSONSerialization.jsonObject(with: data)
            return metadata as? Metadata ?? nil
        } catch {
            throw MetadataParserError.deserializationFailure
        }
    }
    
}
