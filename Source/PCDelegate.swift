public protocol PCDelegate {
    func messageReceived(room: PCRoom, message: PCMessage)

    // TODO: lol no, use ^^ when it works proper

    func messageReceived(roomId: Int, message: PCMessage)

    // TODO: Add user who did the adding

    func addedTo(room: PCRoom)
    //    func removedFromRoom(room: PCRoom, by: PCUser)

    //    func userSubscriptionStateChanged(from: PCUserSubscriptionState, to: PCUserSubscriptionState)

    func userJoined(room: PCRoom, user: PCUser)
    func userLeft(room: PCRoom, user: PCUser)

    //    func roomDeleted(room: PCRoom, deletedBy: PCUser)

    func error(eventType: PCAPIEventType, error: Error)
}
