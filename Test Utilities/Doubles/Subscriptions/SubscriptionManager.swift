import XCTest
@testable import PusherChatkit

public class DummySubscriptionManager: DummyBase, SubscriptionManager {
    
    public func subscribe(toType subscriptionType: SubscriptionType, sender: AnyObject, completion: @escaping SubscribeHandler) {
        DummyFail(sender: self, function: #function)
    }
    
    public func unsubscribe(fromType subscriptionType: SubscriptionType, sender: AnyObject) {
        DummyFail(sender: self, function: #function)
    }
    
    public func unsubscribeFromAll() {
        DummyFail(sender: self, function: #function)
    }
    
}
