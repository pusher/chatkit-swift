struct PCPresencePayload {
    let userId: Int
    let state: PCPresenceState
    let lastSeenAt: String?
}

public enum PCPresenceState: String {
    case online
    case offline
    case unknown
}
