import Foundation

public enum PresenceState {
    
    case unknown
    case offline
    case online
    
    // MARK: - Initializers
    
    init(state: String?) {
        switch state {
        case "offline":
            self = .offline
            
        case "online":
            self = .online
            
        default:
            self = .unknown
        }
    }
    
}

// MARK: - Model

extension PresenceState: Model {
}
