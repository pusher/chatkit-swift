import Foundation

struct PCPresencePayload {
    let state: PCPresenceState
}

public enum PCPresenceState: String {
    case online
    case offline
    case unknown
}
