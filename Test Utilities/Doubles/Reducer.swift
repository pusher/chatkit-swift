import XCTest
@testable import PusherChatkit

public class DummyReducer<ActionType: Action, StateType: State>: DummyBase {
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    public func reducer(action: ActionType, state: StateType) -> StateType {
        DummyFail(sender: self, function: #function)
        return state
    }
    
}

public class StubReducer<ActionType: Action, StateType: State>: StubBase {
    
    private var reducer_expectedCallCount: UInt
    private var reducer_stateToReturn: StateType
    public private(set) var reducer_actionLastReceived: ActionType?
    public private(set) var reducer_stateLastReceived: StateType?
    public private(set) var reducer_actualCallCount: UInt = 0
    
    public init(reducer_stateToReturn: StateType,
                reducer_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.reducer_stateToReturn = reducer_stateToReturn
        self.reducer_expectedCallCount = reducer_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func reducer(action: ActionType, state: StateType) -> StateType {
        reducer_actionLastReceived = action
        reducer_stateLastReceived = state
        reducer_actualCallCount += 1
        
        guard reducer_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return state
        }
        reducer_expectedCallCount -= 1
        
        return reducer_stateToReturn
    }
}
