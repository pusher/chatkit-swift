import Foundation

struct UserDataSerializer {
    
    // MARK: - Public methods
    
    static func serialize(userData: UserData) -> Data? {
        return JSONSerialization.isValidJSONObject(userData) ? try? JSONSerialization.data(withJSONObject: userData) : nil
    }
    
    static func deserialize(data: Data?) -> UserData? {
        guard let data = data else {
            return nil
        }
        
        guard let userData = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        return userData as? UserData ?? nil
    }
    
}
