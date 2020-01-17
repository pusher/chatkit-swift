import XCTest
@testable import PusherChatkit


class DummyStoreBroadcaster: DummyStoreDelegate, StoreBroadcaster {
    
    func register(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
}
