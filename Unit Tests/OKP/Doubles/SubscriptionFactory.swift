import XCTest
@testable import PusherChatkit


class DummySubscriptionFactory: DummyBase, SubscriptionFactory {
    func makeSubscription() -> Subscription {
        return DummySubscription(file: file, line: line)
    }
}

    
class StubSubscriptionFactory: StubBase, SubscriptionFactory {
    
    private var makeSubscription_subscriptionToReturn: Subscription?
    
    init(makeSubscription_subscriptionToReturn: Subscription?,
         file: StaticString = #file, line: UInt = #line) {
        
        self.makeSubscription_subscriptionToReturn = makeSubscription_subscriptionToReturn
        
        super.init(file: file, line: line)
    }
    
    func makeSubscription() -> Subscription {
        guard let makeSubscription_subscriptionToReturn = self.makeSubscription_subscriptionToReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return DummySubscription(file: file, line: line)
        }
        return makeSubscription_subscriptionToReturn
    }
}
