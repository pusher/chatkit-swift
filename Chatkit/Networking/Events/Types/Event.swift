import Foundation

struct Event {
    
    // MARK: - Properties
    
    let name: Name
    let payload: [String : Any]
    
    // MARK: - Initializers
    
    init?(with jsonObject: Any) {
        guard let jsonObject = jsonObject as? [String : Any],
            let nameString = jsonObject[Key.eventName] as? String,
            let name = Name(rawValue: nameString),
            let payload = jsonObject[Key.data] as? [String : Any] else {
            return nil
        }
        
        self.name = name
        self.payload = payload
    }
    
}

// MARK: - Type

extension Event {
    
    enum Name: String {
        
        case initialState = "initial_state"
        
    }
    
}

// MARK: - Keys

extension Event {
    
    struct Key {
        
        static let createdAt = "created_at"
        static let customData = "custom_data"
        static let data = "data"
        static let deletedAt = "deleted_at"
        static let eventName = "event_name"
        static let identifier = "id"
        static let name = "name"
        static let `private` = "private"
        static let rooms = "rooms"
        static let unreadCount = "unread_count"
        static let updatedAt = "updated_at"
        
    }
    
}
