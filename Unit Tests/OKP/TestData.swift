@testable import PusherChatkit


struct JsonString {
    
    static func user() -> String {
        
        return """
        {
            "id": "viv",
            "name": "Vivan",
            "created_at": "2017-04-13T14:10:04Z",
            "updated_at": "2017-04-13T14:10:04Z"
        }
        """
    }
    
    enum InitialStateType {
        case withCurrentUserOnly
    }
    
    static func initialState(type: InitialStateType) -> String {
        
        switch type {
            
        case .withCurrentUserOnly:
            return """
            {
            "current_user": \(user()),
                "rooms": [],
                "read_states": [],
                "memberships": [],
            }
            """
        }
    }
    
    static func initialStateSubscriptionEvent(type: InitialStateType) -> String {
        
        return subscriptionEvent(name: .initialState,
                                 data: initialState(type: type))
    }
    
    static func subscriptionEvent(name: Wire.Event.Subscription.Name, data: String) -> String {
        
        return """
            "data": \(data),
            "event_name": "\(name.rawValue)",
            "timestamp": "2017-04-14T14:00:42Z",
        """
        
    }
    
}



