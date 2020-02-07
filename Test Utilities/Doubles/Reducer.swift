import XCTest
@testable import PusherChatkit

public class DummyReducer<StateType: State>: DummyBase {
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    public func reducer(action: Action, state: StateType) -> StateType {
        DummyFail(sender: self, function: #function)
        return state
    }
    
}

public class StubReducer<StateType: State>: StubBase {
    
    private var reducer_expectedCallCount: UInt
    private var reducer_expectedState: StateType
    public private(set) var reducer_actionLastReceived: Action?
    public private(set) var reducer_stateLastReceived: StateType?
    public private(set) var reducer_actualCallCount: UInt = 0
    
    public init(reducer_expectedState: StateType,
                reducer_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.reducer_expectedState = reducer_expectedState
        self.reducer_expectedCallCount = reducer_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func reducer(action: Action, state: StateType) -> StateType {
        reducer_actionLastReceived = action
        reducer_stateLastReceived = state
        reducer_actualCallCount += 1
        
        guard reducer_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return state
        }
        reducer_expectedCallCount -= 1
        
        return reducer_expectedState
    }
}
