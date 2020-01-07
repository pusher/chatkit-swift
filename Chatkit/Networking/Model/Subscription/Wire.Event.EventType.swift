import Foundation

extension Wire.Event {

    enum EventType {
        // User Subscription
        case initialState(event: Wire.Event.InitialState)
        case addedToRoom(event: Wire.Event.AddedToRoom)
        case removedFromRoom(event: Wire.Event.RemovedFromRoom)
        case roomUpdated(event: Wire.Event.RoomUpdated)
        case roomDeleted(event: Wire.Event.RoomDeleted)
        case userJoinedRoom(event: Wire.Event.UserJoinedRoom)
        case userLeftRoom(event: Wire.Event.UserLeftRoom)
        case readStateUpdated(event: Wire.Event.ReadStateUpdated)
        
        // Room Subscription
        case newMessage(event: Wire.Message)
        case isTyping(event: Wire.Event.IsTyping)
        
        // Presence Subscription
        case presenceState(event: Wire.Event.PresenceState)
        
        var description: String {
            return String(describing: self)
        }
    }
    
}
