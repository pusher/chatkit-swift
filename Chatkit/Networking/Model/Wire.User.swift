import Foundation


extension Wire {

    internal struct User {
        let identifier: String
        let name: String
        let avatarURL: URL?
        let customData: [String: AnyHashable]?
        let createdAt: Date
        let updatedAt: Date
        let deletedAt: Date?
    }
    
}

extension Wire.User: Equatable {}

extension Wire.User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case avatarURL = "avatar_url"
        case customData = "custom_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
    
    // A custom Decodable implementation is required because `customData: [String: Any]?` cannot be auto synthensized
    // (Cannot automatically synthesize 'Decodable' because '[String : Any]?' does not conform to 'Decodable')
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.name = try container.decode(String.self, forKey: .name)
        self.avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatarURL)
        self.customData = try container.decodeIfPresent([String: AnyHashable].self, forKey: .customData)
        self.createdAt = try container.decode(type(of: self.createdAt), forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
        
}
