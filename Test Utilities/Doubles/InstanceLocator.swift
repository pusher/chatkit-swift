import XCTest
@testable import PusherChatkit

extension XCTest {
    // We might like to use a `DummyInstanceLocator` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    public func DummyInstanceLocator(file: StaticString = #file, line: UInt = #line) -> DummyInstanceLocator {
        let dummy: DummyInstanceLocator = .init(file: file, line: line)
        return dummy
    }
}

public class DummyInstanceLocator: DummyBase, InstanceLocator {
    
    public var region: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    
    public var identifier: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    
    public var version: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
}
