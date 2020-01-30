import XCTest
@testable import PusherChatkit

public class DummySubscriptionDelegate: DummyBase, SubscriptionDelegate {
    
    public func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data) {
        DummyFail(sender: self, function: #function)
    }

    public func subscription(_ subscription: Subscription, didReceiveError error: Error) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubSubscriptionDelegate: StubBase, SubscriptionDelegate {

    private var didReceiveEvent_expectedCallCount: UInt
    public private(set) var didReceiveEvent_jsonDataLastReceived: Data?
    public private(set) var didReceiveEvent_callCount: UInt = 0
    
    private var didReceiveError_expectedCallCount: UInt
    public private(set) var didReceiveError_errorLastReceived: Error?
    public private(set) var didReceiveError_callCount: UInt = 0

    public init(didReceiveEvent_expectedCallCount: UInt = 0,
         didReceiveError_expectedCallCount: UInt = 0,
         file: StaticString = #file, line: UInt = #line) {
        
        self.didReceiveEvent_expectedCallCount = didReceiveEvent_expectedCallCount
        self.didReceiveError_expectedCallCount = didReceiveError_expectedCallCount
        
        super.init(file: file, line: line)
    }

    // MARK: SubscriptionDelegate

    public func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data) {
        didReceiveEvent_jsonDataLastReceived = jsonData
        didReceiveEvent_callCount = didReceiveEvent_callCount + 1
        guard didReceiveEvent_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        didReceiveEvent_expectedCallCount = didReceiveEvent_expectedCallCount - 1
    }
    
    public func subscription(_ subscription: Subscription, didReceiveError error: Error) {
        didReceiveError_errorLastReceived = error
        didReceiveError_callCount = didReceiveError_callCount + 1
        guard didReceiveError_expectedCallCount > 0 else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        didReceiveError_expectedCallCount = didReceiveError_expectedCallCount - 1
    }
}
