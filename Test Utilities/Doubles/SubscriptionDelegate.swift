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

public class StubSubscriptionDelegate: DoubleBase, SubscriptionDelegate {

    private let didReceiveEvent_expectedCallCount: UInt
    public private(set) var didReceiveEvent_jsonDataLastReceived: Data?
    public private(set) var didReceiveEvent_actualCallCount: UInt = 0
    
    private let didReceiveError_expectedCallCount: UInt
    public private(set) var didReceiveError_errorLastReceived: Error?
    public private(set) var didReceiveError_actualCallCount: UInt = 0

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
        didReceiveEvent_actualCallCount += 1
        guard didReceiveEvent_actualCallCount <= didReceiveEvent_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
    
    public func subscription(_ subscription: Subscription, didReceiveError error: Error) {
        didReceiveError_errorLastReceived = error
        didReceiveError_actualCallCount += 1
        guard didReceiveError_actualCallCount <= didReceiveError_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
}
