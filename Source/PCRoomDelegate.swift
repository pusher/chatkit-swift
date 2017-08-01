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
}
