import XCTest
@testable import PusherChatkit

class DummyStoreBroadcaster: DummyStoreDelegate, StoreBroadcaster {
    
    func register(_ listener: StoreListener) -> State {
        DummyFail(sender: self, function: #function)
        return State.emptyState
    }
    
    func unregister(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
}
