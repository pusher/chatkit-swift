import XCTest
@testable import PusherChatkit


public class DummyReducer<R: Reducing>: DummyBase {
    
    public typealias T = R.T
    
    public func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
        DummyFail(sender: self, function: #function)
        return state
    }
    
}

extension XCTest {
    // We might like to use a `DummyReducer` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    public func DummyReducer<T: Reducing>(file: StaticString = #file, line: UInt = #line) -> DummyReducer<T> {
        let dummy: DummyReducer<T> = .init(file: file, line: line)
        return dummy
    }
}

public class StubReducer<R: Reducing>: StubBase {
    
    public typealias T = R.T
    
    private var reduce_expectedCallCount: UInt
    private var reduce_expectedState: T.StateType
    public private(set) var reduce_actionLastReceived: T.ActionType?
    public private(set) var reduce_stateLastReceived: T.StateType?
    public private(set) var reduce_actualCallCount: UInt = 0
    
    public init(reduce_expectedState: R.T.StateType,
                reduce_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.reduce_expectedState = reduce_expectedState
        self.reduce_expectedCallCount = reduce_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
        reduce_actionLastReceived = action
        reduce_stateLastReceived = state
        reduce_actualCallCount += 1
        
        guard reduce_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return state
        }
        reduce_expectedCallCount -= 1
        
        return reduce_expectedState
    }
    
}

