import XCTest
@testable import PusherChatkit

public class DummyStoreBroadcaster: DummyStoreDelegate, StoreBroadcaster {
    
    public func register(_ listener: StoreListener) -> VersionedState {
        DummyFail(sender: self, function: #function)
        return .initial
    }
    
    public func unregister(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
}
