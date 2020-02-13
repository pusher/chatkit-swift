import XCTest
@testable import PusherChatkit


public class DummyReducer<T: Reducing>: DummyBase {
    
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

public class StubReducer<T: Reducing>: StubBase {
    
    private let reduce_expectedCallCount: UInt
    private var reduce_stateToReturn: T.StateType
    public private(set) var reduce_actionLastReceived: T.ActionType?
    public private(set) var reduce_stateLastReceived: T.StateType?
    public private(set) var reduce_actualCallCount: UInt = 0
    
    public init(reduce_stateToReturn: T.StateType,
                reduce_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.reduce_stateToReturn = reduce_stateToReturn
        self.reduce_expectedCallCount = reduce_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
        reduce_actionLastReceived = action
        reduce_stateLastReceived = state
        reduce_actualCallCount += 1
        
        guard reduce_actualCallCount <= reduce_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return state
        }
        
        return reduce_stateToReturn
    }
    
}

