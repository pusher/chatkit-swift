import XCTest
@testable import PusherChatkit

public class DummySubscriptionActionDispatcher: DummySubscriptionDelegate, SubscriptionActionDispatcher {}

public class StubSubscriptionActionDispatcher: StubSubscriptionDelegate, SubscriptionActionDispatcher {}
