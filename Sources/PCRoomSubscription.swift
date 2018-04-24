import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    weak var messageSubscription: PCMessageSubscription?
    weak var cursorSubscription: PCCursorSubscription?
    public weak var delegate: PCRoomDelegate?

    init(
        messageSubscription: PCMessageSubscription,
        cursorSubscription: PCCursorSubscription,
        delegate: PCRoomDelegate
    ) {
        self.messageSubscription = messageSubscription
        self.cursorSubscription = cursorSubscription
        self.delegate = delegate
    }

    func end() {
        self.messageSubscription?.end()
        self.cursorSubscription?.end()
        
        self.messageSubscription = nil
        self.cursorSubscription = nil
    }
}
