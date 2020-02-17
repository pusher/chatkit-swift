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
            let instanceLocator = PusherPlatform.InstanceLocator(string: instanceLocatorString)!
            let dependencies = ConcreteDependencies(instanceLocator: instanceLocator, tokenProvider: tokenProvider)
            
            let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
            
            let initialState = dependencies.storeBroadcaster.register(stubStoreListener)
            
            XCTAssertEqual(initialState, .empty)
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
            
            XCTAssertEqual(expectation.result, .success)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
            XCTAssertNotNil(stubStoreListener.didUpdateState_stateLastReceived?.currentUser)
            
        }())
    }
}
