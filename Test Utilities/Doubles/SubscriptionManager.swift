import XCTest
@testable import PusherChatkit

public class DummySubscriptionManager: DummyBase, SubscriptionManager {
    
    public func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        DummyFail(sender: self, function: #function)
    }
    
    public func unsubscribe(_ subscriptionType: SubscriptionType) {
        DummyFail(sender: self, function: #function)
    }
    
    public func unsubscribeFromAll() {
        DummyFail(sender: self, function: #function)
    }
    
}
