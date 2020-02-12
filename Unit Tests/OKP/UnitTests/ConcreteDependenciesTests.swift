import TestUtilities
import XCTest
import struct PusherPlatform.InstanceLocator
@testable import PusherChatkit

class ConcreteDependenciesTests: XCTestCase {
    
    let instanceLocator = PusherPlatform.InstanceLocator(string: "version:region:identifier")!
    
    func test_initWithoutOverride_withInstanceLocatorButNoOverride_returnsConcreteDependencies() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = self.instanceLocator
        let tokenProvider = DummyTokenProvider()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dependencies = ConcreteDependencies(instanceLocator: instanceLocator,
                                                tokenProvider: tokenProvider)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(dependencies.instanceLocator.version, "version")
        XCTAssertEqual(dependencies.instanceLocator.region, "region")
        XCTAssertEqual(dependencies.instanceLocator.identifier, "identifier")
        XCTAssertTrue(dependencies.tokenProvider is DummyTokenProvider)
        XCTAssertTrue(dependencies.sdkInfoProvider is ConcreteSDKInfoProvider)
        XCTAssertTrue(dependencies.storeBroadcaster is ConcreteStoreBroadcaster)
        XCTAssertTrue(dependencies.store is ConcreteStore)
        XCTAssertTrue(dependencies.instanceFactory is ConcreteInstanceFactory)
        XCTAssertTrue(dependencies.subscriptionResponder is ConcreteSubscriptionResponder)
        XCTAssertTrue(dependencies.subscriptionFactory is ConcreteSubscriptionFactory)
        XCTAssertTrue(dependencies.subscriptionManager is ConcreteSubscriptionManager)
    }
    
    func test_initWithInstanceLocatorAndOverride_withInstanceLocatorAndOverride_overridesDepedencies() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = self.instanceLocator
        let tokenProvider = DummyTokenProvider()
        
        let expectation = self.expectation(description: "`override` closure should be called on `ConcreteDependencies`")
        let override: (DependencyFactory) -> Void = { dependencyFactory in
            dependencyFactory.register(Store.self) { dependencies in
                StubStore()
            }
            expectation.fulfill()
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dependencies = ConcreteDependencies(instanceLocator: instanceLocator,
                                                tokenProvider: tokenProvider,
                                                override: override)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(dependencies.instanceLocator.version, "version")
        XCTAssertEqual(dependencies.instanceLocator.region, "region")
        XCTAssertEqual(dependencies.instanceLocator.identifier, "identifier")
        XCTAssertTrue(dependencies.sdkInfoProvider is ConcreteSDKInfoProvider)
        XCTAssertTrue(dependencies.storeBroadcaster is ConcreteStoreBroadcaster)
        XCTAssertTrue(dependencies.store is StubStore) // <------ Not a `ConcreteStore`!
        XCTAssertTrue(dependencies.instanceFactory is ConcreteInstanceFactory)
        XCTAssertTrue(dependencies.subscriptionResponder is ConcreteSubscriptionResponder)
        XCTAssertTrue(dependencies.subscriptionFactory is ConcreteSubscriptionFactory)
        XCTAssertTrue(dependencies.subscriptionManager is ConcreteSubscriptionManager)
    }
    
    // This tests the extension methods in `TestUtilities`
    func test_initWithInstanceFactory_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubNetworking = StubNetworking()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dependencies = ConcreteDependencies(instanceFactory: stubNetworking)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(dependencies.instanceFactory is StubNetworking)
    }
    
    func test_initWithInstanceLocatorAndInstanceFactory_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = self.instanceLocator
        let stubNetworking = StubNetworking()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dependencies = ConcreteDependencies(instanceLocator: instanceLocator, instanceFactory: stubNetworking)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(dependencies.instanceFactory is StubNetworking)
    }
    
}
