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
    
    func test_chatkitMakeJoinedRoomsRepository_regardless_returnsInClosedState() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitInitialised()

            /*****************/
            /*---- WHEN -----*/
            /*****************/

            let joinedRoomsRepository = chatkit.makeJoinedRoomsRepository()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertEqual(joinedRoomsRepository.state, JoinedRoomsRepositoryState.closed(error: nil))
            
        }())
    }
    
}
