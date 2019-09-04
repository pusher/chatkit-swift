import Foundation

struct MetadataSerializer {
    
    // MARK: - Public methods
    
    static func serialize(metadata: Metadata) -> Data? {
        return JSONSerialization.isValidJSONObject(metadata) ? try? JSONSerialization.data(withJSONObject: metadata) : nil
    }
    
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
