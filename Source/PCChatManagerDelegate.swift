import Foundation

public protocol PCChatManagerDelegate {
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
    func userCameOnline(user: PCUser)
    func userWentOffline(user: PCUser)

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
    func userCameOnline(user: PCUser) {}
    func userWentOffline(user: PCUser) {}
    func error(error: Error) {}
}
