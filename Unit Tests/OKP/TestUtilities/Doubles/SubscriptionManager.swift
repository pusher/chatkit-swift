import XCTest
@testable import PusherChatkit

class DummySubscriptionManager: DummyBase, SubscriptionManager {
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        DummyFail(sender: self, function: #function)
    }
}
