import XCTest
@testable import PusherChatkit

public class DummyStoreListener: DummyBase, StoreListener {
    
    public func store(_ store: Store, didUpdateState state: MasterState) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubStoreListener: StubBase, StoreListener {

    private var didUpdateState_expectedCallCount: UInt
    public private(set) var didUpdateState_stateLastReceived: MasterState?
    public private(set) var didUpdateState_actualCallCount: UInt = 0

    public init(didUpdateState_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }

    // MARK: StoreListener
    
    public func store(_ store: Store, didUpdateState state: MasterState) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        didUpdateState_expectedCallCount -= 1
    }
}
