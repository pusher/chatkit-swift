import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    let messageSubscription: PCMessageSubscription
    let cursorSubscription: PCCursorSubscription

    // TODO: Maybe the RoomSubscription should just store the delegate?
    public var delegate: PCRoomDelegate? {
        get {
            return messageSubscription.delegate
        }
    }

    init(
        messageSubscription: PCMessageSubscription,
        cursorSubscription: PCCursorSubscription
    ) {
        self.messageSubscription = messageSubscription
        self.cursorSubscription = cursorSubscription
    }

    func end() {
        self.messageSubscription.end()
        self.cursorSubscription.end()
    }
}
