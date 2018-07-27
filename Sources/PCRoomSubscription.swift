import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    var messageSubscription: PCMessageSubscription?
    var cursorSubscription: PCCursorSubscription?
    var membershipSubscription: PCMembershipSubscription?
    public weak var delegate: PCRoomDelegate?

    init(
        messageSubscription: PCMessageSubscription,
        cursorSubscription: PCCursorSubscription,
        membershipSubscription: PCMembershipSubscription,
        delegate: PCRoomDelegate
    ) {
        self.messageSubscription = messageSubscription
        self.cursorSubscription = cursorSubscription
        self.membershipSubscription = membershipSubscription
        self.delegate = delegate
    }

    func end() {
        self.messageSubscription?.end()
        self.cursorSubscription?.end()
        self.membershipSubscription?.end()
        
        self.messageSubscription = nil
        self.cursorSubscription = nil
        self.membershipSubscription = nil
    }
}
