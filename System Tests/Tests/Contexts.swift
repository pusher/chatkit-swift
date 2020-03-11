import Environment
import TestUtilities
import XCTest
@testable import PusherChatkit

extension XCTestCase {

    /*
     System Test "Contexts" Explained
     
        ChatKitInitialised
            `Chatkit` instance has been initialised,
            `Chatkit.connect()` HAS NOT been invoked

        ChakitConnected
            `Chatkit` instance has been initialised
            `chatkit.connect()` HAS been invoked and handler called with `success`
            (i.e. the user subscription IS active)
                under the hood the *user* subscription has been successfully registered
                AND its `initial_state` event has been returned (`connect()` does not complete without this)
     
        ChatkitConnectFailure
            `Chatkit` instance has been initialised
            `chatkit.connect()` HAS been invoked and handler called with `failure`
            (i.e. the user subscription is NOT active)

        JoinedRoomsRepositoryInitialised
        As "ChakitConnected" but also
            `JoinedRoomsRepository` instance has been initialised (via `chatKit.makeJoinedRoomsRepository()`)
    */
    
    func setUp_ChatKitInitialised(file: StaticString = #file, line: UInt = #line) throws -> Chatkit {
        
        let instanceLocatorString = Environment.instanceLocator
        let userIdentifier = "pusher-quick-start-bob"
        let tokenProvider = try TestTokenProvider(instanceLocator: instanceLocatorString, userIdentifier: userIdentifier)
        
        let chatkit = try Chatkit(instanceLocator: instanceLocatorString, tokenProvider: tokenProvider)
        
        return chatkit
    }
    
    func setUp_ChatKitConnected(file: StaticString = #file, line: UInt = #line) throws -> Chatkit {

        let chatkit = try setUp_ChatKitInitialised(file: file, line: line)

        let expectation = XCTestExpectation.Chatkit.connect
        chatkit.connect(completionHandler: expectation.handler)
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, nil)
        
        return chatkit
    }
    
}
