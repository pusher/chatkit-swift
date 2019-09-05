import Foundation

struct MetadataParser {
    
    // MARK: - Public methods
    
    static func deserialize(data: Data?) -> Metadata? {
        guard let data = data else {
            return nil
        }
        
        guard let metadata = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        return metadata as? Metadata ?? nil
    }
    
}
