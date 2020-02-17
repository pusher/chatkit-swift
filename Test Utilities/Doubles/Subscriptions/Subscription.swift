import XCTest
@testable import PusherChatkit

public class DummySubscription: DummyBase, Subscription {
    
    public func subscribe(completion: @escaping (VoidResult) -> Void) {
        DummyFail(sender: self, function: #function)
    }
    
    public func unsubscribe() {
        DummyFail(sender: self, function: #function)
    }
}

public class StubSubscription: DoubleBase, Subscription {
    
    private var subscribe_completionResults: [VoidResult]
    public private(set) var subscribe_actualCallCount: UInt = 0
    
    private let unsubscribe_expectedCallCount: UInt
    public private(set) var unsubscribe_actualCallCount: UInt = 0
    
    private let delegate: SubscriptionDelegate?
    
    private var isSubscribed = false
            
    public init(subscribe_completionResults: [VoidResult] = [],
                unsubscribe_expectedCallCount: UInt = 0,
                delegate: SubscriptionDelegate?,
                file: StaticString = #file, line: UInt = #line) {
        
        self.subscribe_completionResults = subscribe_completionResults
        self.unsubscribe_expectedCallCount = unsubscribe_expectedCallCount
        self.delegate = delegate
        
        super.init(file: file, line: line)
    }
    
    public func fireSubscriptionEvent(jsonData: Data) {
        guard isSubscribed else {
            XCTFail("Unexpected call to \(#function) on \(String(describing: self)) when not subscribed", file: file, line: line)
            return
        }
        delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
    }
    
    // MARK: Subscription
    
    public func subscribe(completion: @escaping (VoidResult) -> Void) {
        subscribe_actualCallCount += 1
        
        guard let subscribe_completionResult = self.subscribe_completionResults.removeOptionalFirst() else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        
        if case .success = subscribe_completionResult {
            isSubscribed = true
        } else {
            isSubscribed = false
        }
        
        completion(subscribe_completionResult)
    }
    
    public func unsubscribe() {
        unsubscribe_actualCallCount += 1
        guard unsubscribe_actualCallCount <= unsubscribe_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        isSubscribed = false
    }
}
