import TestUtilities
import XCTest
@testable import PusherChatkit

class System_ChatkitConnected_Tests: XCTestCase {
    
    func test_chatkitConnect_completesWithoutErrorAndRemainsConnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitConnected()

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
    
    func test_chatkitDisconnect_becomesDisconnected() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitConnected()

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

}