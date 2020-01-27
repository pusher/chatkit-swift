import Foundation

/// An enumeration representing presence state of a user.
public enum PresenceState {
    
    /// The value representing unknown presence state.
    case unknown
    
    /// The value representing offline presence state.
    case offline
    
    /// The value representing online presence state.
    case online
    
    // MARK: - Initializers
    
    init(state: String?) {
        switch state?.lowercased() {
        case "offline":
            self = .offline
            
        case "online":
            self = .online
            
        default:
            self = .unknown
        }
    }
    
}
