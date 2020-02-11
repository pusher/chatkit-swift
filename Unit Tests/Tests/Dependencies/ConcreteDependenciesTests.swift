import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteDependenciesTests: XCTestCase {
    
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

        // TODO work out how to test this, not sure its possible?
//        XCTAssertFalse(dependencies.reducer_master === Reducer.Master.reduce)
//        XCTAssertFalse(dependencies.reducer_model_user_forInitialState === Reducer.Model.User_forInitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_model_rooms_forInitialState === Reducer.Model.Rooms_forInitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_model_rooms_forRemovedFromRoom === Reducer.Model.Rooms_forRemovedFromRoom.reduce)
//        XCTAssertFalse(dependencies.reducer_userSubscription_initialState === Reducer.UserSubscription.InitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_userSubscription_removedFromRoom === Reducer.UserSubscription.RemovedFromRoom.reduce)
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
