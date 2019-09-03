import Foundation

struct Event {
    
    // MARK: - Properties
    
    let name: Name
    let payload: [String : Any]
    
    // MARK: - Initializers
    
    init?(with jsonObject: Any) {
        guard let jsonObject = jsonObject as? [String : Any],
            let nameString = jsonObject["event_name"] as? String,
            let name = Name(rawValue: nameString),
            let payload = jsonObject["data"] as? [String : Any] else {
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
