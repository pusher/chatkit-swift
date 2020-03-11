import XCTest
@testable import PusherChatkit

extension XCTest {
    
    // We often need to use a `Dummy` directly in a test so here we provide
    // a set of (faux) initialisers that set `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // We restrict this to within XCTest only because if we are outside of a
    // test we always want the callee to pass a specific file & line so that
    // any assertion failures bubble up to within the test itself.
    
    public func DummyStore(file: StaticString = #file, line: UInt = #line) -> DummyStore {
        let dummy: DummyStore = .init(file: file, line: line)
        return dummy
    }

    public func DummySubscription(file: StaticString = #file, line: UInt = #line) -> DummySubscription {
        let dummy: DummySubscription = .init(file: file, line: line)
        return dummy
    }
    
    public func DummySubscriptionDelegate(file: StaticString = #file, line: UInt = #line) -> DummySubscriptionDelegate {
        let dummy: DummySubscriptionDelegate = .init(file: file, line: line)
        return dummy
    }
    
    public func DummyTokenProvider(file: StaticString = #file, line: UInt = #line) -> DummyTokenProvider {
        let dummy: DummyTokenProvider = .init(file: file, line: line)
        return dummy
    }
    
    public func DummyInstanceWrapper(file: StaticString = #file, line: UInt = #line) -> DummyInstanceWrapper {
        let dummy: DummyInstanceWrapper = .init(file: file, line: line)
        return dummy
    }
    
    public func DummyResumableSubscription(file: StaticString = #file, line: UInt = #line) -> DummyResumableSubscription {
        let dummy: DummyResumableSubscription = .init(file: file, line: line)
        return dummy
    }

}
