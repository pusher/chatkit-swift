import TestUtilities
import XCTest
@testable import PusherChatkit

class Functional_ChatkitInitialised_Tests: XCTestCase {
    
    func test_chatkitConnect_whenUserSubscriptionSucceeds_completesWithoutErrorAndBecomesConnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (stubNetworking, chatkit) = try setUp_ChatKitInitialised()

            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            // Prepare user subscription to open and fire event when the client attempts to subscribe
            stubNetworking.stubSubscribe(.user, .open(initialStateJsonData: initialStateJsonData))
            
            let expectation = XCTestExpectation.Chatkit.connect
            chatkit.connect(completionHandler: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: 1)
            
            XCTAssertExpectationFulfilledWithResult(expectation, nil)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
            
        }())
    }
    
    func test_chatkitConnect_whenUserSubscriptionFails_completesWithErrorAndRemainsDisconnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (stubNetworking, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            // Prepare user subscription to return failure when the client attempts to register
            stubNetworking.stubSubscribe(.user, .fail(error: "Failure"))
            
            let expectation = XCTestExpectation.Chatkit.connect
            chatkit.connect(completionHandler: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: 1)
            
            XCTAssertExpectationFulfilledWithResult(expectation, "Failure")
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
            
        }())
    }
    
    func test_chatkitDisconnect_regardless_remainsDisconnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            chatkit.disconnect()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
            
        }())
    }
    
    func test_chatkitCreateJoinedRoomsProvider_regardless_completesWithErrorBecauseNotConnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = XCTestExpectation.Chatkit.createJoinedRoomsProvider
            chatkit.createJoinedRoomsProvider(completionHandler: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertExpectationFulfilled(expectation) { joinedRoomsProvider, error in
                XCTAssertNil(joinedRoomsProvider)
                // TODO: improved assertion to better check content of error
                XCTAssertNotNil(error)
            }
            
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
            
        }())
    }

}
