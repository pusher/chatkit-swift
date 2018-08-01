import Foundation

public protocol PCChatManagerDelegate: AnyObject {
    func addedToRoom(room: PCRoom)
    func removedFromRoom(room: PCRoom)
    func roomUpdated(room: PCRoom)
    func roomDeleted(room: PCRoom)

    // These _can_ be implemented as part of the PCUserSubscriptionDelegate, but
    // the primary usage is intended at the Room level (see PCRoomDelegate)
    func userStartedTyping(room: PCRoom, user: PCUser)
    func userStoppedTyping(room: PCRoom, user: PCUser)
    func userJoinedRoom(room: PCRoom, user: PCUser)
    func userLeftRoom(room: PCRoom, user: PCUser)
    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser)

    // TODO: Is this the best way of communicating errors? What errors are
    // communicated using this?
    func error(error: Error)
}

public extension PCChatManagerDelegate {
    func addedToRoom(room: PCRoom) {}
    func removedFromRoom(room: PCRoom) {}
    func roomUpdated(room: PCRoom) {}
    func roomDeleted(room: PCRoom) {}
    func userStartedTyping(room: PCRoom, user: PCUser) {}
    func userStoppedTyping(room: PCRoom, user: PCUser) {}
    func userJoinedRoom(room: PCRoom, user: PCUser) {}
    func userLeftRoom(room: PCRoom, user: PCUser) {}
    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {}
    func error(error: Error) {}
}
