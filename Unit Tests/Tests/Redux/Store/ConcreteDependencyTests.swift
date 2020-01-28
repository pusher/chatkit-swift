import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class ConcreteDependencyTests: XCTestCase {
    
    func test_initWithInstanceLocator_success() {
        
        let dependencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator)
        
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? ConcreteStore)
    }
    
    func test_initWithInstanceLocatorAndOverride_success() {
        
        let expectation = self.expectation(description: "`override` closure should be called on `ConcreteDependencies`")
        
        let dependencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator) { dependencyFactory in
            dependencyFactory.register(Store.self) { dependencies in
                StubStore()
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? StubStore)
    }
    
}
