import XCTest
@testable import PusherChatkit

public class DummyStore: DummyBase, Store {
    
    public var state: VersionedState {
        DummyFail(sender: self, function: #function)
        return .initial
    }
    
    public func dispatch(action: Action) {
        DummyFail(sender: self, function: #function)
    }
    
    public func register(_ listener: StoreListener) -> VersionedState {
        DummyFail(sender: self, function: #function)
        return .initial
    }
    
    public func unregister(_ listener: StoreListener) {
        DummyFail(sender: self, function: #function)
    }
    
}

public class StubStore: DoubleBase, Store {
    
    private var register_statesToReturn: [VersionedState]
    public private(set) weak var register_listenerLastReceived: StoreListener?
    public private(set) var register_actualCallCount: Int = 0
    
    private let dispatch_expectedCallCount: UInt
    public private(set) var dispatch_lastReceived: Action?
    public private(set) var dispatch_actualCallCount: UInt = 0
    
    private let unregister_expectedCallCount: UInt
    public private(set) var unregister_actualCallCount: Int = 0
    
    public init(register_stateToReturn: VersionedState? = nil,
                dispatch_expectedCallCount: UInt = 0,
                register_expectedCallCount: UInt = 0,
                unregister_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        if let register_stateToReturn = register_stateToReturn {
            self.register_statesToReturn = [register_stateToReturn]
        } else {
            self.register_statesToReturn = []
        }
        
        self.dispatch_expectedCallCount = dispatch_expectedCallCount
        self.unregister_expectedCallCount = unregister_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func dispatch(action: Action) {
        self.dispatch_actualCallCount += 1
        self.dispatch_lastReceived = action
        
        guard dispatch_actualCallCount <= dispatch_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return
        }
    }
    
    public func register(_ listener: StoreListener) -> VersionedState {
        self.register_listenerLastReceived = listener
        self.register_actualCallCount += 1
        
        guard let register_stateToReturn = register_statesToReturn.removeOptionalFirst() else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return .initial
        }
        return register_stateToReturn
    }
    
    public func unregister(_ listener: StoreListener) {
        self.unregister_actualCallCount += 1
        
        guard self.unregister_actualCallCount <= self.unregister_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return
        }
    }
    
    public func report(_ state: VersionedState) {
        self.register_listenerLastReceived?.store(self, didUpdateState: state)
    }
    
}
