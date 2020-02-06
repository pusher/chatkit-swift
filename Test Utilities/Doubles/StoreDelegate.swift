import XCTest
@testable import PusherChatkit

public class DummyStoreDelegate: DummyBase, StoreDelegate {
    
    public func store(_ store: Store, didUpdateState state: ChatState) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubStoreDelegate: StubBase, StoreDelegate {

    private var didUpdateState_expectedCallCount: UInt
    public private(set) var didUpdateState_stateLastReceived: ChatState?
    public private(set) var didUpdateState_actualCallCount: Int = 0

    public init(didUpdateState_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }

    // MARK: StoreDelegate
    
    public func store(_ store: Store, didUpdateState state: ChatState) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        guard didUpdateState_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        didUpdateState_expectedCallCount -= 1
    }
}
