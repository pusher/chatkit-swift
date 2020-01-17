import XCTest
@testable import PusherChatkit


class DummySubscription: DummyBase, Subscription {
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping (Result<Void, Error>) -> Void) {
        DummyFail(sender: self, function: #function)
    }
}

extension XCTest {
    // We might like to use a `DummySubscription` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    func DummySubscription(file: StaticString = #file, line: UInt = #line) -> DummySubscription {
        let dummy: DummySubscription = .init(file: file, line: line)
        return dummy
    }
}

class StubSubscription: StubBase, Subscription {
    
    private var subscribe_completionResult: Result<Void, Error>?
    private let delegate: SubscriptionDelegate?
    
    private var isSubscribed = false
    private(set) var action_lastReceived: Action?
    
    init(subscribe_completionResult: Result<Void, Error>,
         delegate: SubscriptionDelegate?,
         file: StaticString = #file, line: UInt = #line) {
        
        self.subscribe_completionResult = subscribe_completionResult
        self.delegate = delegate
        
        super.init(file: file, line: line)
    }
    
    func fireSubscriptionEvent(jsonData: Data) {
        guard isSubscribed else {
            XCTFail("Unexpected call to \(#function) on \(String(describing: self)) when not subscribed", file: file, line: line)
            return
        }
        self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
    }
    
    // MARK: Subscription
    
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping (Result<Void, Error>) -> Void) {
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
