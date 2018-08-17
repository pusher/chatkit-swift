import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    var messageSubscription: PCMessageSubscription?
    var cursorSubscription: PCCursorSubscription?
    var membershipSubscription: PCMembershipSubscription?
    public weak var delegate: PCChatManagerDelegate? {
        didSet {
            messageSubscription?.delegate = delegate
            cursorSubscription?.delegate = delegate
            membershipSubscription?.delegate = delegate
        }
    }

    init(
        messageSubscription: PCMessageSubscription,
        cursorSubscription: PCCursorSubscription,
        membershipSubscription: PCMembershipSubscription,
        delegate: PCChatManagerDelegate
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
