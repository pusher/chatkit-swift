import XCTest
@testable import PusherChatkit

public class DummySubscriptionFactory: DummyBase, SubscriptionFactory {
    
    public func makeSubscription(subscriptionType: SubscriptionType) -> Subscription {
        return DummySubscription(file: file, line: line)
    }
}

public class StubSubscriptionFactory: DoubleBase, SubscriptionFactory {
    
    private var makeSubscription_expectedTypesAndSubscriptionsToReturn: [(subscriptionType: SubscriptionType, subscription: Subscription)]
    public private(set) var makeSubscription_actualCallCount: UInt = 0
    
    public init(makeSubscription_expectedTypesAndSubscriptionsToReturn: [(subscriptionType: SubscriptionType, subscription: Subscription)] = [],
         file: StaticString = #file, line: UInt = #line) {
        
        self.makeSubscription_expectedTypesAndSubscriptionsToReturn = makeSubscription_expectedTypesAndSubscriptionsToReturn
        
        super.init(file: file, line: line)
    }
    
    public func makeSubscription(subscriptionType: SubscriptionType) -> Subscription {
        makeSubscription_actualCallCount += 1
        
        guard let (expectedSubscriptionType, subscriptionToReturn) = self.makeSubscription_expectedTypesAndSubscriptionsToReturn.removeOptionalFirst() else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return DummySubscription(file: file, line: line)
        }
        guard expectedSubscriptionType == subscriptionType else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self)) with `subscriptionType` of `\(subscriptionType)`.  Was expecting a `subscriptionType` of `\(expectedSubscriptionType)`", file: file, line: line)
            return DummySubscription(file: file, line: line)
        }
        
        return subscriptionToReturn
    }
}
