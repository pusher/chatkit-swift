import XCTest
@testable import PusherChatkit

public class DummyStore: DummyBase, Store {
    
    public var state: State {
        DummyFail(sender: self, function: #function)
        return State.empty
    }
    
    public func action(_ action: Action) {
        DummyFail(sender: self, function: #function)
    }
}

public extension XCTest {
    // We might like to use a `DummyStore` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    func DummyStore(file: StaticString = #file, line: UInt = #line) -> DummyStore {
        let dummy: DummyStore = .init(file: file, line: line)
        return dummy
    }
}

public class StubStore: StubBase, Store {

    private var state_toReturn: State?
    public private(set) var state_actualCallCount: UInt = 0
    
    private var action_expectedCallCount: UInt
    public private(set) var action_lastReceived: Action?
    public private(set) var action_actualCallCount: UInt = 0
    
    public init(state_toReturn: State? = nil,
         action_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.state_toReturn = state_toReturn
        self.action_expectedCallCount = action_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    // MARK: Store
    
    public var state: State {
        state_actualCallCount += 1
        guard let state_toReturn = state_toReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return State.empty
        }
        return state_toReturn
    }
    
    public func action(_ action: Action) {
        action_actualCallCount += 1
        action_lastReceived = action
        guard self.action_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        action_expectedCallCount -= 1
    }
    
}
