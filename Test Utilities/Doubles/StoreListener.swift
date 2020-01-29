import XCTest
@testable import PusherChatkit

class DummyStoreListener: DummyBase, StoreListener {
    func store(_ store: Store, didUpdateState state: State) {
        DummyFail(sender: self, function: #function)
    }
}

class StubStoreListener: StubBase, StoreListener {

    private var didUpdateState_expectedCallCount: UInt
    private(set) var didUpdateState_stateLastReceived: State?
    private(set) var didUpdateState_actualCallCount: UInt = 0

    init(didUpdateState_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }

    // MARK: StoreListener
    
    func store(_ store: Store, didUpdateState state: State) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        didUpdateState_expectedCallCount -= 1
    }
}
