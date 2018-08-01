import Foundation
import PusherPlatform

public protocol PCRoomDelegate: NSObjectProtocol {
    func newMessage(message: PCMessage)

    func userStartedTyping(user: PCUser)
    func userStoppedTyping(user: PCUser)

    func userJoined(user: PCUser)
    func userLeft(user: PCUser)

    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser)

    func newCursor(cursor: PCCursor)

    // TODO: This seems like it could instead be `userListUpdated`, or something similar?
    func usersUpdated()
}

public extension PCRoomDelegate {
    func newMessage(message: PCMessage) {}
    func userStartedTyping(user: PCUser) {}
    func userStoppedTyping(user: PCUser) {}
    func userJoined(user: PCUser) {}
    func userLeft(user: PCUser) {}
    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {}
    func newCursor(cursor: PCCursor) {}
    func usersUpdated() {}
}
