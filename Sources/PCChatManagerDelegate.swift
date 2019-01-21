import Foundation

public protocol PCChatManagerDelegate: AnyObject {
    func onAddedToRoom(_ room: PCRoom)
    func onRemovedFromRoom(_ room: PCRoom)
    func onRoomUpdated(room: PCRoom)
    func onRoomDeleted(room: PCRoom)

    // These _can_ be implemented as part of the PCChatManagerDelegate, but
    // the primary usage is intended at the Room level (see PCRoomDelegate)
    func onUserStartedTyping(inRoom room: PCRoom, user: PCUser)
    func onUserStoppedTyping(inRoom room: PCRoom, user: PCUser)
    func onUserJoinedRoom(_ room: PCRoom, user: PCUser)
    func onUserLeftRoom(_ room: PCRoom, user: PCUser)
    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser)
    func onNewReadCursor(_ cursor: PCCursor)

    // TODO: Is this the best way of communicating errors? What errors are
    // communicated using this?
    func onError(error: Error)
}

public extension PCChatManagerDelegate {
    func onAddedToRoom(_ room: PCRoom) {}
    func onRemovedFromRoom(_ room: PCRoom) {}
    func onRoomUpdated(room: PCRoom) {}
    func onRoomDeleted(room: PCRoom) {}
    func onUserStartedTyping(inRoom: PCRoom, user: PCUser) {}
    func onUserStoppedTyping(inRoom: PCRoom, user: PCUser) {}
    func onUserJoinedRoom(_ room: PCRoom, user: PCUser) {}
    func onUserLeftRoom(_ room: PCRoom, user: PCUser) {}
    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {}
    func onNewReadCursor(_ cursor: PCCursor) {}
    func onError(error: Error) {}
}
