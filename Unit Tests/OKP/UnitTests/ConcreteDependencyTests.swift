import XCTest
@testable import PusherChatkit

class ConcreteDependencyTests: XCTestCase {
    
    func test_initWithInstanceLocator_success() {
        
        let dependencies = ConcreteDependencies(instanceLocator: "dummy:instance:locator")
        
        XCTAssertNotNil(dependencies.sdkInfoProvider as? ConcreteSDKInfoProvider)
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? ConcreteStore)
        XCTAssertNotNil(dependencies.instanceFactory as? ConcreteInstanceFactory)
        XCTAssertNotNil(dependencies.subscriptionResponder as? ConcreteSubscriptionResponder)
        XCTAssertNotNil(dependencies.subscriptionFactory as? ConcreteSubscriptionFactory)
        XCTAssertNotNil(dependencies.subscriptionManager as? ConcreteSubscriptionManager)
        XCTAssertNotNil(dependencies.userService as? ConcreteUserService)
        XCTAssertNotNil(dependencies.missingUserFetcher as? ConcreteMissingUserFetcher)
    }
    
    func test_initWithInstanceLocatorAndOverride_success() {
        
        let expectation = self.expectation(description: "`override` closure called on `ConcreteDependencies`")
        
        let dependencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator) { dependencyFactory in
            dependencyFactory.register(Store.self) { dependencies in
                StubStore()
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(dependencies.sdkInfoProvider as? ConcreteSDKInfoProvider)
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? StubStore)
        XCTAssertNotNil(dependencies.instanceFactory as? ConcreteInstanceFactory)
        XCTAssertNotNil(dependencies.subscriptionResponder as? ConcreteSubscriptionResponder)
        XCTAssertNotNil(dependencies.subscriptionFactory as? ConcreteSubscriptionFactory)
        XCTAssertNotNil(dependencies.subscriptionManager as? ConcreteSubscriptionManager)
        XCTAssertNotNil(dependencies.userService as? ConcreteUserService)
        XCTAssertNotNil(dependencies.missingUserFetcher as? ConcreteMissingUserFetcher)
    }
    
    func test_initWithInstanceFactory_success() {
        
        let stubNetworking = StubNetworking()
        
        let dependencies = ConcreteDependencies(instanceFactory: stubNetworking)
        
        XCTAssertNotNil(dependencies.instanceFactory as? StubNetworking)
    }
    
    func test_initWithInstanceLocatorAndInstanceFactory_success() {
        
        let stubNetworking = StubNetworking()
        
        let dependencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator, instanceFactory: stubNetworking)
        
        XCTAssertNotNil(dependencies.instanceFactory as? StubNetworking)
    }
    
}
