import XCTest
@testable import PusherChatkit

public class DummySubscriptionManager: DummyBase, SubscriptionManager {
    
    public func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        DummyFail(sender: self, function: #function)
    }
}
