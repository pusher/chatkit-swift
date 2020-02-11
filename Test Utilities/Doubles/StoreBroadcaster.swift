import XCTest
@testable import PusherChatkit

public class DummyStoreBroadcaster: DummyStoreDelegate, StoreBroadcaster {
    
    public func register(_ listener: StoreListener) -> MasterState {
        DummyFail(sender: self, function: #function)
        return MasterState.empty
    }
    
    public func unregister(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
}
