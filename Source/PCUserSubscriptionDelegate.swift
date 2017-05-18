public protocol PCUserSubscriptionDelegate {

    // TODO: Remove?
//    func messageReceived(room: PCRoom, message: PCMessage)


    func addedToRoom(_ room: PCRoom)
    func removedFromRoom(_ room: PCRoom)
    func roomUpdated(_ room: PCRoom)
    func roomDeleted(_ room: PCRoom)
    func userJoinedRoom(_ room: PCRoom, user: PCUser)
    func userLeftRoom(_ room: PCRoom, user: PCUser)

    // TODO: These two are moving
    func userStartedTyping(_ room: PCRoom, user: PCUser)
    func userStoppedTyping(_ room: PCRoom, user: PCUser)

    func error(_ error: Error)

//    func userSubscriptionStateChanged(from: PCUserSubscriptionState, to: PCUserSubscriptionState)
}
