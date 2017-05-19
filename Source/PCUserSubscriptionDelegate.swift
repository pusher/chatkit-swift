public protocol PCUserSubscriptionDelegate {
    // TODO: Remove? Currently we ignore, I think
//    func messageReceived(room: PCRoom, message: PCMessage)

    func addedToRoom(_ room: PCRoom)
    func removedFromRoom(_ room: PCRoom)
    func roomUpdated(_ room: PCRoom)
    func roomDeleted(_ room: PCRoom)

    // These _can_ be implemented as part of the PCUserSubscriptionDelegate, but
    // the primary usage is envisaged at the Room level (PCRoomDelegate)
    func userStartedTypingInRoom(_ room: PCRoom, user: PCUser)
    func userStoppedTypingInRoom(_ room: PCRoom, user: PCUser)
    func userJoinedRoom(_ room: PCRoom, user: PCUser)
    func userLeftRoom(_ room: PCRoom, user: PCUser)

    // TODO: Is this the best way of communicating errors? What errors are
    // communicated using this?
    func error(_ error: Error)

//    func userSubscriptionStateChanged(from: PCUserSubscriptionState, to: PCUserSubscriptionState)
}

extension PCUserSubscriptionDelegate {
    public func userStartedTypingInRoom(_ room: PCRoom, user: PCUser) {}
    public func userStoppedTypingInRoom(_ room: PCRoom, user: PCUser) {}
    public func userJoinedRoom(_ room: PCRoom, user: PCUser) {}
    public func userLeftRoom(_ room: PCRoom, user: PCUser) {}
}
