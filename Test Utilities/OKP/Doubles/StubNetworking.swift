import XCTest
@testable import PusherChatkit

public class StubNetworking: DoubleBase, InstanceWrapperFactory {
    
    private var expectedSubscribeCalls: [SubscriptionType: VoidResult] = .init()
    private var expectedSubscriptionEndCalls: Set<SubscriptionType> = .init()
    private var registeredStubInstanceWrappers: [InstanceType: StubInstanceWrapper] = .init()
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    // MARK: Faux Networking
    
    // TODO: Preparing for CRUD requests.  Needs to be implemented in future.
    public func stub(_ urlString: String, _ jsonData: Data) {}
    
    // Preparing for registration to a subscription
    public func stubSubscribe(_ subscriptionType: SubscriptionType, _ result: VoidResult,
                              file: StaticString = #file, line: UInt = #line) {
        guard expectedSubscribeCalls[subscriptionType] == nil else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)` made but we are *already* anticipating a call to `subscribe` that has not yet been fulfilled", file: file, line: line)
            return
        }
        
        if let stubInstanceWrapper = registeredStubInstanceWrappers[.subscription(subscriptionType)] {
            stubInstanceWrapper.stubSubscribe(result: result)
        } else {
            expectedSubscribeCalls[subscriptionType] = result
        }
    }
    
    public func stubSubscriptionEnd(_ subscriptionType: SubscriptionType) {
        guard !expectedSubscriptionEndCalls.contains(subscriptionType) else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)` made but we are *already* anticipating a call to end the subscription that has not yet been fulfilled", file: file, line: line)
            return
        }
        
        if let stubInstanceWrapper = registeredStubInstanceWrappers[.subscription(subscriptionType)] {
            stubInstanceWrapper.stubResumableSubscriptionEnd()
        } else {
            expectedSubscriptionEndCalls.insert(subscriptionType)
        }
    }
    
    // MARK: Live firing of subscription events
    
    public func fireSubscriptionEvent(_ subscriptionType: SubscriptionType, _ jsonData: Data,
                                      file: StaticString = #file, line: UInt = #line) {
        guard let stubInstanceWrapper = registeredStubInstanceWrappers[.subscription(subscriptionType)] else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)`", file: file, line: line)
            return
        }
        stubInstanceWrapper.fireOnEvent(jsonData: jsonData)
    }
    
    // Live firing of subscription error
    public func fireSubscriptionError(_ subscriptionType: SubscriptionType, error: Error,
                                      file: StaticString = #file, line: UInt = #line) {
        guard let stubInstanceWrapper = registeredStubInstanceWrappers[.subscription(subscriptionType)] else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)`", file: file, line: line)
            return
        }
        stubInstanceWrapper.fireOnError(error: error)
    }
    
    public func fireSubscriptiOnEnd(_ subscriptionType: SubscriptionType,
                                    file: StaticString = #file, line: UInt = #line) {
            guard let stubInstanceWrapper = registeredStubInstanceWrappers[.subscription(subscriptionType)] else {
                XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)`", file: file, line: line)
                return
            }
            stubInstanceWrapper.fireOnEnd()
        }
    
    // MARK: InstanceWrapperFactory
    
    public func makeInstanceWrapper(forType instanceType: InstanceType) -> InstanceWrapper {
        
        let dummyInstanceWrapper = DummyInstanceWrapper(file: file, line: line)
        
        guard registeredStubInstanceWrappers[instanceType] == nil else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` made but an instanceWrapper already exists for the specified instanceType: `\(instanceType)`", file: file, line: line)
            return dummyInstanceWrapper
        }
        
        switch instanceType {
            
        case let .subscription(subscriptionType):
        
            guard let expectedVoidResult = expectedSubscribeCalls[subscriptionType] else {
                XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with instanceType: `\(instanceType)`", file: file, line: line)
                return dummyInstanceWrapper
            }
            
            expectedSubscribeCalls[subscriptionType] = nil
            
            let stubInstanceWrapper = StubInstanceWrapper(file: file, line: line)
            stubInstanceWrapper.stubSubscribe(result: expectedVoidResult)
            
            if expectedSubscriptionEndCalls.contains(subscriptionType) {
                stubInstanceWrapper.stubResumableSubscriptionEnd()
            }
            
            registeredStubInstanceWrappers[instanceType] = stubInstanceWrapper
            
            return stubInstanceWrapper
        }
    }
}
