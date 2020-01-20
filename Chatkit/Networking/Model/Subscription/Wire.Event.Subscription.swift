import Foundation

extension Wire.Event {

    internal struct Subscription {
        
        let eventName: Name
        let data: EventType
        let timestamp: Date
        
        enum Name: String {
            // User Subscription
            case initialState = "initial_state"
            case addedToRoom = "added_to_room"
            case removedFromRoom = "removed_from_room"
            case roomUpdated = "room_updated"
            case roomDeleted = "room_deleted"
            case userJoinedRoom = "user_joined_room"
            case userLeftRoom = "user_left_room"
            case readStateUpdated = "read_state_updated"
            // Room Subscription
            case newMessage = "new_message"
            case isTyping = "is_typing"
            // Presence Subscription
            case presenceState = "presence_state"
        }
    }

}

extension Wire.Event.Subscription.Name: Decodable {}

extension Wire.Event.Subscription: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case data
        case timestamp

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventName = try container.decode(Name.self, forKey: .eventName)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        switch eventName {
        
        // User Subscription
            
        case .initialState:
            let event = try container.decode(Wire.Event.InitialState.self, forKey: .data)
            self.data = .initialState(event: event)
        
        case .addedToRoom:
            let event = try container.decode(Wire.Event.AddedToRoom.self, forKey: .data)
            self.data = .addedToRoom(event: event)

        case .removedFromRoom:
            let event = try container.decode(Wire.Event.RemovedFromRoom.self, forKey: .data)
            self.data = .removedFromRoom(event: event)
            
        case .roomUpdated:
            let event = try container.decode(Wire.Event.RoomUpdated.self, forKey: .data)
            self.data = .roomUpdated(event: event)
            
        case .roomDeleted:
            let event = try container.decode(Wire.Event.RoomDeleted.self, forKey: .data)
            self.data = .roomDeleted(event: event)

        case .userJoinedRoom:
            let event = try container.decode(Wire.Event.UserJoinedRoom.self, forKey: .data)
            self.data = .userJoinedRoom(event: event)
            
        case .userLeftRoom:
            let event = try container.decode(Wire.Event.UserLeftRoom.self, forKey: .data)
            self.data = .userLeftRoom(event: event)
            
        case .readStateUpdated:
            let event = try container.decode(Wire.Event.ReadStateUpdated.self, forKey: .data)
            self.data = .readStateUpdated(event: event)

        // Room Subscription
            
        case .newMessage:
            let event = try container.decode(Wire.Event.NewMessage.self, forKey: .data)
            self.data = .newMessage(event: event)
            
        case .isTyping:
            let event = try container.decode(Wire.Event.IsTyping.self, forKey: .data)
            self.data = .isTyping(event: event)
        
        // Presence Subscription
            
        case .presenceState:
            let event = try container.decode(Wire.Event.PresenceState.self, forKey: .data)
            self.data = .presenceState(event: event)
        }
    }
}

