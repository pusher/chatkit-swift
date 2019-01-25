import Foundation
import PusherPlatform

public protocol PCRoomDelegate: AnyObject {
    func onMessage(_ message: PCMessage)

    @available(*, deprecated, renamed: "onNewReadCursor")
    func onNewCursor(_ cursor: PCCursor)

    func onNewReadCursor(_ cursor: PCCursor)

    func onUserStartedTyping(user: PCUser)
    func onUserStoppedTyping(user: PCUser)

    func onUserJoined(user: PCUser)
    func onUserLeft(user: PCUser)

    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser)

    // TODO: This should be unnecessary
    func onUsersUpdated()
}

public extension PCRoomDelegate {
    func onMessage(_ message: PCMessage) {}
    func onNewCursor(_ cursor: PCCursor) {}
    func onNewReadCursor(_ cursor: PCCursor) {}
    func onUserStartedTyping(user: PCUser) {}
    func onUserStoppedTyping(user: PCUser) {}
    func onUserJoined(user: PCUser) {}
    func onUserLeft(user: PCUser) {}
    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {}
    func onUsersUpdated() {}
}
