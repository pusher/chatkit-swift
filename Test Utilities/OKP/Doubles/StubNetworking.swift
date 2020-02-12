import XCTest
@testable import PusherChatkit

public class StubNetworking: DoubleBase, InstanceFactory {
    
    private var expectedSubscribeCalls: [SubscriptionType: VoidResult] = .init()
    private var expectedSubscriptionEndCalls: Set<SubscriptionType> = .init()
    private var registeredStubInstances: [InstanceType: StubInstance] = .init()
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    // MARK: Faux Networking
    
    // Preparing for CRUD requests
    public func stub(_ urlString: String, _ jsonData: Data) {}
    
    // Preparing for registration to a subscription
    public func stubSubscribe(_ subscriptionType: SubscriptionType, _ result: VoidResult,
                       file: StaticString = #file, line: UInt = #line) {
        guard expectedSubscribeCalls[subscriptionType] == nil else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)` made but we are *already* anticipating a call to `subscribe` that has not yet been fulfilled", file: file, line: line)
            return
        }
        
        if let stubInstance = registeredStubInstances[.subscription(subscriptionType)] {
            stubInstance.stubSubscribe(result: result)
        } else {
            expectedSubscribeCalls[subscriptionType] = result
        }
    }
    
    public func stubSubscriptionEnd(_ subscriptionType: SubscriptionType) {
        guard !expectedSubscriptionEndCalls.contains(subscriptionType) else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)` made but we are *already* anticipating a call to end the subscription that has not yet been fulfilled", file: file, line: line)
            return
        }
        
        if let stubInstance = registeredStubInstances[.subscription(subscriptionType)] {
            stubInstance.stubSubscriptionEnd()
        } else {
            expectedSubscriptionEndCalls.insert(subscriptionType)
        }
    }
    
    // Live firing of subscription events
    public func fireSubscriptionEvent(_ subscriptionType: SubscriptionType, _ jsonData: Data,
                               file: StaticString = #file, line: UInt = #line) {
        guard let stubInstance = registeredStubInstances[.subscription(subscriptionType)] else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)`", file: file, line: line)
            return
        }
        stubInstance.fireSubscriptionEvent(jsonData: jsonData)
    }
    
    // Live firing of subscription error
    public func fireSubscriptionError(_ subscriptionType: SubscriptionType, _httpCode: Int, _ jsonData: Data,
                               file: StaticString = #file, line: UInt = #line) {
        guard let stubInstance = registeredStubInstances[.subscription(subscriptionType)] else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with subscriptionType: `\(subscriptionType)`", file: file, line: line)
            return
        }
        // TODO:
        preconditionFailure()
//        stubInstance.fireSubscriptionError()
    }
    
    // MARK: InstanceFactory
    
    public func makeInstance(forType instanceType: InstanceType) -> Instance {
        
        let dummyInstance = DummyInstance(file: file, line: line)
        
        guard registeredStubInstances[instanceType] == nil else {
            XCTFail("Call to `\(#function)` on `\(String(describing: self))` made but an instance already exists for the specified instanceType: `\(instanceType)`", file: file, line: line)
            return dummyInstance
        }
        
        switch instanceType {
            
        case let .subscription(subscriptionType):
        
            guard let expectedVoidResult = expectedSubscribeCalls[subscriptionType] else {
                XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with instanceType: `\(instanceType)`", file: file, line: line)
                return dummyInstance
            }
            
            expectedSubscribeCalls[subscriptionType] = nil
            
            let stubInstance = StubInstance(file: file, line: line)
            stubInstance.stubSubscribe(result: expectedVoidResult)
            
            if expectedSubscriptionEndCalls.contains(subscriptionType) {
                stubInstance.stubSubscriptionEnd()
            }
            
            registeredStubInstances[instanceType] = stubInstance
            
            return stubInstance
            
        case .service:
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))` with instanceType: `\(instanceType)`", file: file, line: line)
            return DummyInstance(file: file, line: line)
        }
    }
}