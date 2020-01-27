import Foundation

extension Wire {

    internal struct Room {
        let identifier: String
        let name: String
        let createdById: String
        let isPrivate: Bool
        let pushNotificationTitleOverride: String?
        let customData: [String: AnyHashable]?
        let lastMessageAt: Date?
        let createdAt: Date
        let updatedAt: Date
        let deletedAt: Date?
    }

}

extension Wire.Room: Equatable {}

extension Wire.Room: Decodable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case createdById = "created_by_id"
        case pushNotificationTitleOverride = "push_notification_title_override"
        case customData = "custom_data"
        case isPrivate = "private"
        case lastMessageAt = "last_message_at"
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
        self.createdById = try container.decode(String.self, forKey: .createdById)
        self.pushNotificationTitleOverride = try container.decodeIfPresent(String.self, forKey: .pushNotificationTitleOverride)
        self.customData = try container.decodeIfPresent([String: AnyHashable].self, forKey: .customData)
        self.isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        self.lastMessageAt = try container.decodeIfPresent(Date.self, forKey: .lastMessageAt)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }
}
