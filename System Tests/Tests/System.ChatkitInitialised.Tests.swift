import TestUtilities
import XCTest
@testable import PusherChatkit

class System_ChatKitInitialised_Tests: XCTestCase {
    
    func test_chatkitConnect_completesWithoutErrorAndBecomesConnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitInitialised()

            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = XCTestExpectation.Chatkit.connect
            chatkit.connect(completionHandler: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertExpectationFulfilledWithResult(expectation, nil)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
            
        }())
    }
    
    func test_chatkitDisconnect_remainsDisconnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitInitialised()

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
    
    func test_chatkitCreateJoinedRoomsProvider_completesWithErrorBecauseNotConencted() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitInitialised()

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
                XCTAssertNotNil(error)
            }
            
        }())
    }
    
}
