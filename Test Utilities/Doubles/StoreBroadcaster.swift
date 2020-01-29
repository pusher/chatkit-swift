import XCTest
@testable import PusherChatkit

public class DummyStoreBroadcaster: DummyStoreDelegate, StoreBroadcaster {
    
    public func register(_ listener: StoreListener) -> State {
        DummyFail(sender: self, function: #function)
        return State.empty
    }
    
    public func unregister(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
}
