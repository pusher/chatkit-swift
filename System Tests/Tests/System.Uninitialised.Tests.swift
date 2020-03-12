import Environment
import TestUtilities
import XCTest
import struct PusherPlatform.InstanceLocator
@testable import PusherChatkit

class System_UnInitialised_Tests: XCTestCase {
    
    func test_chatkitInit_withValidArguments_returnsNotNil() {
        
        XCTAssertNoThrow(try {

            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let instanceLocatorString = Environment.instanceLocator
            let userIdentifier = "pusher-quick-start-bob"
            let tokenProvider = try TestTokenProvider(instanceLocator: instanceLocatorString, userIdentifier: userIdentifier)
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let chatkit = try Chatkit(instanceLocator: instanceLocatorString, tokenProvider: tokenProvider)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertNotNil(chatkit)
            
        }())
    }
    
    func test_subscriptionManagerSubscribe_withListenerRegisteredWithStoreBroadcaster_listenerIsNotified() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let instanceLocatorString = Environment.instanceLocator
            let userIdentifier = "pusher-quick-start-bob"
            let tokenProvider = try TestTokenProvider(instanceLocator: instanceLocatorString, userIdentifier: userIdentifier)
            let instanceLocator = InstanceLocator(string: instanceLocatorString)!
            let dependencies = ConcreteDependencies(instanceLocator: instanceLocator, tokenProvider: tokenProvider)
            
            let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 3)
            
            let initialState = dependencies.store.register(stubStoreListener)
            
            XCTAssertEqual(initialState, .initial)
            XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = XCTestExpectation.SubscriptionManager.subscribe
            dependencies.subscriptionManager.subscribe(toType: .user, sender: self, completion: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            // There are 3 state changes output from  the store
            //      1. Subscription's ConnectionState changes to `subscribing`
            //      2. Subscription's ConnectionState changes to `connected`
            //      3. initialState populates all the RoomListState and CurrentUserState etc.
            
            XCTAssertEqual(expectation.result, .success)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 3)
            XCTAssertNotNil(stubStoreListener.didUpdateState_stateLastReceived?.chatState.currentUser)
            
        }())
    }
}
