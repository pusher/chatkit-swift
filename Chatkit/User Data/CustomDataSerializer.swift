import Foundation

struct CustomDataSerializer {
    
    // MARK: - Public methods
    
    static func serialize(customData: CustomData) -> Data? {
        return JSONSerialization.isValidJSONObject(customData) ? try? JSONSerialization.data(withJSONObject: customData) : nil
    }
    
    static func deserialize(data: Data?) -> CustomData? {
        guard let data = data else {
            return nil
        }
        
        guard let customData = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        return customData as? CustomData ?? nil
    }
}
