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
    
    func test_chatkitMakeJoinedRoomsRepository_returnsInConnectedState() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitConnected()

            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let joinedRoomsRepository = chatkit.makeJoinedRoomsRepository()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            if case let .connected(rooms, changeReason) = joinedRoomsRepository.state {
                XCTAssertGreaterThan(rooms.count, 0)
                XCTAssertEqual(changeReason, nil)
            } else {
                XCTFail("Unexpected state - \(joinedRoomsRepository.state)")
            }
            
            
        }())
    }

}
