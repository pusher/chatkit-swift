import Foundation

struct PCPresencePayload {
    let userId: String
    let state: PCPresenceState
    let lastSeenAt: String?
}

public enum PCPresenceState: String {
    case online
    case offline
    case unknown
}
