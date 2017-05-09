public protocol PCDelegate {
    func messageReceived(room: PCRoom, message: PCMessage)

    // TODO: lol no, use ^^ when it works proper

    func messageReceived(roomId: Int, message: PCMessage)

    func addedToRoom(_ room: PCRoom)
    func removedFromRoom(_ room: PCRoom)
    func roomUpdated(_ room: PCRoom)
    func roomDeleted(_ room: PCRoom)

    func userJoinedRoom(_ room: PCRoom, user: PCUser)
    func userLeftRoom(_ room: PCRoom, user: PCUser)

    func error(_ error: Error)


//    func userSubscriptionStateChanged(from: PCUserSubscriptionState, to: PCUserSubscriptionState)
}
