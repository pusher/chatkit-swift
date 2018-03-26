import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    let messageSubscription: PCMessageSubscription
    let cursorSubscription: PCCursorSubscription
    public var delegate: PCRoomDelegate

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
        self.messageSubscription.end()
        self.cursorSubscription.end()
    }
}
