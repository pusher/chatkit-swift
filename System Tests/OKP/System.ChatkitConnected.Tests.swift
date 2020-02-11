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
                  
            XCTAssertExpectationFulfilled(expectation) { error in
                XCTAssertNil(error)
            }
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
    
    func test_chatkitCreateJoinedRoomsProvider_completesWithJoinedRoomsProvider() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let chatkit = try setUp_ChatKitConnected()

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
                XCTAssertNotNil(joinedRoomsProvider) { joinedRoomsProvider in
                    print(joinedRoomsProvider.rooms)
                    XCTAssertGreaterThan(joinedRoomsProvider.rooms.count, 0)
                }
                XCTAssertNil(error)
            }
            
        }())
    }

}
