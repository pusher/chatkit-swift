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
         XCTAssertTrue(dependencies.instanceWrapperFactory is ConcreteInstanceWrapperFactory)
         XCTAssertTrue(dependencies.subscriptionActionDispatcher is ConcreteSubscriptionActionDispatcher)
         XCTAssertTrue(dependencies.subscriptionFactory is ConcreteSubscriptionFactory)
         XCTAssertTrue(dependencies.subscriptionManager is ConcreteSubscriptionManager)

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
         
         let instanceLocator = self.instanceLocator
         let tokenProvider = DummyTokenProvider()
         
         let expectation = self.expectation(description: "`override` closure should be called on `ConcreteDependencies`")
         let override: (DependencyFactory) -> Void = { dependencyFactory in
             dependencyFactory.register(Store.self) { _ in
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
         XCTAssertTrue(dependencies.instanceWrapperFactory is ConcreteInstanceWrapperFactory)
         XCTAssertTrue(dependencies.subscriptionActionDispatcher is ConcreteSubscriptionActionDispatcher)
         XCTAssertTrue(dependencies.subscriptionFactory is ConcreteSubscriptionFactory)
         XCTAssertTrue(dependencies.subscriptionManager is ConcreteSubscriptionManager)

        // TODO work out how to test this, not sure its possible?
//        XCTAssertFalse(dependencies.reducer_master === Reducer.Master.reduce)
//        XCTAssertFalse(dependencies.reducer_model_user_forInitialState === Reducer.Model.User_forInitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_model_rooms_forInitialState === Reducer.Model.Rooms_forInitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_model_rooms_forRemovedFromRoom === Reducer.Model.Rooms_forRemovedFromRoom.reduce)
//        XCTAssertFalse(dependencies.reducer_userSubscription_initialState === Reducer.UserSubscription.InitialState.reduce)
//        XCTAssertFalse(dependencies.reducer_userSubscription_removedFromRoom === Reducer.UserSubscription.RemovedFromRoom.reduce)
     }
     
     // This tests the extension methods in `TestUtilities`
     func test_initWithInstanceWrapperFactory_success() {
         
         /******************/
         /*---- GIVEN -----*/
         /******************/
         
         let stubNetworking = StubNetworking()
         
         /******************/
         /*----- WHEN -----*/
         /******************/
         
         let dependencies = ConcreteDependencies(instanceWrapperFactory: stubNetworking)
         
         /******************/
         /*----- THEN -----*/
         /******************/
         
         XCTAssertTrue(dependencies.instanceWrapperFactory is StubNetworking)
     }
     
     func test_initWithInstanceLocatorAndInstanceWrapperFactory_success() {
         
         /******************/
         /*---- GIVEN -----*/
         /******************/
         
         let instanceLocator = self.instanceLocator
         let stubNetworking = StubNetworking()
         
         /******************/
         /*----- WHEN -----*/
         /******************/
         
         let dependencies = ConcreteDependencies(instanceLocator: instanceLocator, instanceWrapperFactory: stubNetworking)
         
         /******************/
         /*----- THEN -----*/
         /******************/
         
         XCTAssertTrue(dependencies.instanceWrapperFactory is StubNetworking)
     }
}
