import XCTest
@testable import PusherChatkit

public class DummySubscriptionFactory: DummyBase, SubscriptionFactory {
    
    public func makeSubscription() -> Subscription {
        return DummySubscription(file: file, line: line)
    }
}

public class StubSubscriptionFactory: StubBase, SubscriptionFactory {
    
    private var makeSubscription_subscriptionToReturn: Subscription?
    
    public init(makeSubscription_subscriptionToReturn: Subscription?,
         file: StaticString = #file, line: UInt = #line) {
        
        self.makeSubscription_subscriptionToReturn = makeSubscription_subscriptionToReturn
        
        super.init(file: file, line: line)
    }
    
    public func makeSubscription() -> Subscription {
        guard let makeSubscription_subscriptionToReturn = self.makeSubscription_subscriptionToReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return DummySubscription(file: file, line: line)
        }
        return makeSubscription_subscriptionToReturn
    }
}
