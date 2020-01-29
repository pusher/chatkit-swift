import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class ConcreteDependencyTests: XCTestCase {
    
    func test_initWithInstanceLocator_withInstanceLocatorButNoOverride_returnsConcreteDependencies() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = DummyInstanceLocator()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let dependencies = ConcreteDependencies(instanceLocator: instanceLocator)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? ConcreteStore)
    }
    
    func test_initWithInstanceLocatorAndOverride_withInstanceLocatorAndOverride_overridesDepedencies() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = DummyInstanceLocator()
        
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
                                                override: override)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(dependencies.storeBroadcaster as? ConcreteStoreBroadcaster)
        XCTAssertNotNil(dependencies.store as? StubStore)
    }
    
}
