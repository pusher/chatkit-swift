import XCTest
@testable import PusherChatkit

public class DummyStore: DummyBase, Store {
    
    public var state: MasterState {
        DummyFail(sender: self, function: #function)
        return MasterState.empty
    }
    
    public func dispatch(action: Action) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubStore: DoubleBase, Store {

    private var state_toReturn: MasterState?
    public private(set) var state_actualCallCount: UInt = 0
    
    private var action_expectedCallCount: UInt
    public private(set) var action_lastReceived: Action?
    public private(set) var action_actualCallCount: UInt = 0
    
    public init(state_toReturn: MasterState? = nil,
                action_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.state_toReturn = state_toReturn
        self.action_expectedCallCount = action_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    // MARK: Store
    
    public var state: MasterState {
        state_actualCallCount += 1
        guard let state_toReturn = state_toReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return MasterState.empty
        }
        return state_toReturn
    }
    
    public func dispatch(action: Action) {
        action_actualCallCount += 1
        action_lastReceived = action
        guard action_actualCallCount <= action_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
    
}
