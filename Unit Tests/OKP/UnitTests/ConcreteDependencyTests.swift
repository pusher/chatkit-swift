import XCTest
@testable import PusherChatkit


class ConcreteDependencyTests: XCTestCase {
    
    func test_stuff() {
        
        let dependencies = ConcreteDependencies(instanceLocator: "dummy:instance:locator")
        
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? ConcreteStore)
        XCTAssertNotNil(dependencies.instanceFactory as? ConcreteInstanceFactory)
        XCTAssertNotNil(dependencies.subscriptionResponder as? ConcreteSubscriptionResponder)
        XCTAssertNotNil(dependencies.subscriptionFactory as? ConcreteSubscriptionFactory)
        XCTAssertNotNil(dependencies.subscriptionManager as? ConcreteSubscriptionManager)
        XCTAssertNotNil(dependencies.userService as? UserService)
        XCTAssertNotNil(dependencies.userHydrator as? UserHydrator)
    }
    
    func test_initWithInstanceFactory_success() {
        
        let stubNetworking = StubNetworking()
        
        let dependencies = ConcreteDependencies(instanceFactory: stubNetworking)
        
        XCTAssertNotNil(dependencies.instanceFactory as? StubNetworking)
    }
    
}
