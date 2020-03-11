import XCTest
@testable import PusherChatkit

public class DummyStoreListener: DummyBase, StoreListener {
    
    public func store(_ store: Store, didUpdateState state: VersionedState) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubStoreListener: DoubleBase, StoreListener {

    private var didUpdateState_expectedCallCount: UInt
    public private(set) var didUpdateState_stateLastReceived: VersionedState?
    public private(set) var didUpdateState_actualCallCount: UInt = 0

    public init(didUpdateState_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }

    // MARK: StoreListener
    
    public func store(_ store: Store, didUpdateState state: VersionedState) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_actualCallCount <= didUpdateState_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
}
