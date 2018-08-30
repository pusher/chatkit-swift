import Foundation
import PusherPlatform

public protocol PCRoomDelegate: NSObjectProtocol {
    func onMessage(_ message: PCMessage)

    func onNewCursor(_ cursor: PCCursor)

    func onUserStartedTyping(user: PCUser)
    func onUserStoppedTyping(user: PCUser)

    func onUserJoined(user: PCUser)
    func onUserLeft(user: PCUser)

    func onUserPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser)

    // TODO: This should be unnecessary
    func onUsersUpdated()
}

public extension PCRoomDelegate {
    func onMessage(_ message: PCMessage) {}
    func onNewCursor(_ cursor: PCCursor) {}
    func onUserStartedTyping(user: PCUser) {}
    func onUserStoppedTyping(user: PCUser) {}
    func onUserJoined(user: PCUser) {}
    func onUserLeft(user: PCUser) {}
    func onUserPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {}
    func onUsersUpdated() {}
}
