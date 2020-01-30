import XCTest
@testable import PusherChatkit

public class DummySubscription: DummyBase, Subscription {
    
    public func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping (VoidResult) -> Void) {
        DummyFail(sender: self, function: #function)
    }
}

extension XCTest {
    // We might like to use a `DummySubscription` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    public func DummySubscription(file: StaticString = #file, line: UInt = #line) -> DummySubscription {
        let dummy: DummySubscription = .init(file: file, line: line)
        return dummy
    }
}

public class StubSubscription: StubBase, Subscription {
    
    private var subscribe_completionResult: VoidResult?
    private let delegate: SubscriptionDelegate?
    
    private var isSubscribed = false
    public private(set) var action_lastReceived: Action?
    
    public init(subscribe_completionResult: VoidResult,
         delegate: SubscriptionDelegate?,
         file: StaticString = #file, line: UInt = #line) {
        
        self.subscribe_completionResult = subscribe_completionResult
        self.delegate = delegate
        
        super.init(file: file, line: line)
    }
    
    public func fireSubscriptionEvent(jsonData: Data) {
        guard isSubscribed else {
            XCTFail("Unexpected call to \(#function) on \(String(describing: self)) when not subscribed", file: file, line: line)
            return
        }
        self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
    }
    
    // MARK: Subscription
    
    public func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping (VoidResult) -> Void) {
        guard let subscribe_completionResult = self.subscribe_completionResult else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        
        if case .success = subscribe_completionResult {
            self.isSubscribed = true
        } else {
            self.isSubscribed = false
        }
        
        completion(subscribe_completionResult)
    }
}
