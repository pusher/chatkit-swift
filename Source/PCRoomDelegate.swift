import Foundation
import PusherPlatform

public protocol PCRoomDelegate {
    func newMessage(message: PCMessage)

    func userStartedTyping(user: PCUser)
    func userStoppedTyping(user: PCUser)

    func userJoined(user: PCUser)
    func userLeft(user: PCUser)

    func userCameOnlineInRoom(user: PCUser)
    func userWentOfflineInRoom(user: PCUser)

    // TODO: This seems like it could instead be `userListUpdated`, or something similar?
    func usersUpdated()

    // TODO: I don't think we'll want this - it could be handled by the state change - i.e. changed
    // to .failed, potentially with an associated error value

    // func error(error: Error)

    // TODO: Make all of this work, and probably duplicate in PCChatManagerDelegate

    //    func subscriptionStateChanged(from: PPResumableSubscriptionState, to: PPResumableSubscriptionState)
}

public extension PCRoomDelegate {
    func newMessage(message: PCMessage) {}
    func userStartedTyping(user: PCUser) {}
    func userStoppedTyping(user: PCUser) {}
    func userJoined(user: PCUser) {}
    func userLeft(user: PCUser) {}
    func userCameOnlineInRoom(user: PCUser) {}
    func userWentOfflineInRoom(user: PCUser) {}
    func usersUpdated() {}
}
