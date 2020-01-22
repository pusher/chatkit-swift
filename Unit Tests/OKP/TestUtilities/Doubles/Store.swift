import XCTest
@testable import PusherChatkit


class DummyStore: DummyBase, Store {
    func action(_ action: Action) {
        DummyFail(sender: self, function: #function)
    }
}

extension XCTest {
    // We might like to use a `DummyStore` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    func DummyStore(file: StaticString = #file, line: UInt = #line) -> DummyStore {
        let dummy: DummyStore = .init(file: file, line: line)
        return dummy
    }
}


class StubStore: StubBase, Store {

    private var action_expectedCallCount: UInt
    
    private(set) var action_lastReceived: Action?
    
    init(action_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.action_expectedCallCount = action_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    func action(_ action: Action) {
        guard self.action_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        action_expectedCallCount = action_expectedCallCount - 1
        self.action_lastReceived = action
    }
    
}
