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

public class StubStoreBroadcaster: StubBase, StoreBroadcaster {
    
    private var state_toReturn: VersionedState
    
    private var register_expectedCallCount: UInt
    public private(set) weak var register_listenerLastReceived: StoreListener?
    public private(set) var register_actualCallCount: Int = 0
    
    private var unregister_expectedCallCount: UInt
    public private(set) var unregister_actualCallCount: Int = 0
    
    public init(state_toReturn: VersionedState,
                register_expectedCallCount: UInt = 0,
                unregister_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.state_toReturn = state_toReturn
        self.register_expectedCallCount = register_expectedCallCount
        self.unregister_expectedCallCount = unregister_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func report(_ state: VersionedState) {
        self.register_listenerLastReceived?.store(StubStore(), didUpdateState: state)
    }
    
    public func store(_ store: Store, didUpdateState state: VersionedState) {}
    
    public func register(_ listener: StoreListener) -> VersionedState {
        self.register_listenerLastReceived = listener
        self.register_actualCallCount += 1
        
        guard self.register_actualCallCount <= self.register_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return self.state_toReturn
        }
        
        return self.state_toReturn
    }
    
    public func unregister(_ listener: StoreListener) {
        self.unregister_actualCallCount += 1
        
        guard self.unregister_actualCallCount <= self.unregister_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return
        }
    }
    
}
