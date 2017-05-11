import Foundation
import PusherPlatform

public protocol PCRoomDelegate {
    // TODO: Should the room relevant PCRoom be passed in as a parameter? room: PCRoom

    func newMessage(_ message: PCMessage)


    // TODO: I don't think we'll want this - it could be handled by the state change - i.e. changed
    // to .failed, potentially with an associated error value

    func error(_ error: Error)

    // TODO: Make all of this work, and probably duplicate in PCUserSubscriptionDelegate (PCDelegate)

    func subscriptionStateChanged(from: PPResumableSubscriptionState, to: PPResumableSubscriptionState)
}
