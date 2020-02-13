import TestUtilities
import XCTest
@testable import PusherChatkit


extension XCTestCase {

    /*
     Functional Test "Contexts" Explained
     
        ChatKitInitialised
            `Chatkit` instance has been initialised,
            `Chatkit.connect()` HAS NOT been invoked

        ChakitConnected
            `Chatkit` instance has been initialised
            `chatkit.connect()` HAS been invoked and handler called with `success`
            (i.e. the user subscription IS active)
                under the hood the *user* subscritpion has been successfully registered
                AND its `initial_state` event has been returned (`connect()` does not complete without this)
     
        ChatkitConnectFailure
            `Chatkit` instance has been initialised
            `chatkit.connect()` HAS been invoked and handler called with `failure`
            (i.e. the user subscription is NOT active)

        JoinedRoomsProviderInitialised
            As "ChakitConnected" but also
            `JoinedRoomsProvider` instance has been initialised (via `chatKit.makeJoinedRoomsProvider()`)
     
    */
    
    // TODO: remove this method & returning of `dependencies` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_ChatKitInitialised_withDependencies(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, Dependencies) {
        
        let stubNetworking = StubNetworking(file: file, line: line)
        let dependencies = ConcreteDependencies(instanceFactory: stubNetworking)
        
        let chatkit = try Chatkit(dependencies: dependencies)
        
        return (stubNetworking, chatkit, dependencies)
    }
        
    func setUp_ChatKitInitialised(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit) {
        
        let (stubNetworking, chatkit, _) = try setUp_ChatKitInitialised_withDependencies(file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
    func setUp_ChatKitConnected(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit) {

        let (stubNetworking, chatkit, _) = try setUp_ChatKitConnected_withStoreBroadcaster(initialState: initialStateJsonData, file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
    // TODO: remove this method & returning of `storeBroadcaster` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_ChatKitConnected_withStoreBroadcaster(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, StoreBroadcaster) {

        let (stubNetworking, chatkit, dependencies) = try setUp_ChatKitInitialised_withDependencies(file: file, line: line)
        
        // Prepare for the client to register for a user subscription
        // Fire the "initial_state" User subscription event which will cause `Chatkit` to become successfully `connected`
        stubNetworking.stubSubscribe(.user, .success)
        
        let expectation = XCTestExpectation.Chatkit.connect
        chatkit.connect(completionHandler: expectation.handler)
        
        stubNetworking.fireSubscriptionEvent(.user, initialStateJsonData)
        
        wait(for: [expectation], timeout: expectation.timeout)

        XCTAssertExpectationFulfilledWithResult(expectation, nil)
        XCTAssertEqual(chatkit.connectionStatus, .connected, file: file, line: line)
        
        return (stubNetworking, chatkit, dependencies.storeBroadcaster)
    }
    
    func setUp_JoinedRoomsProviderInitialised(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, JoinedRoomsProvider) {
        
        let (stubNetworking, chatkit) = try setUp_ChatKitConnected(initialState: initialStateJsonData, file: file, line: line)
        
        let expectation = XCTestExpectation.Chatkit.createJoinedRoomsProvider
        chatkit.createJoinedRoomsProvider(completionHandler: expectation.handler)
        
        wait(for: [expectation], timeout: 1)

        XCTAssertExpectationFulfilled(expectation) { joinedRoomsProvider, error in
            XCTAssertNotNil(joinedRoomsProvider)
            XCTAssertNil(error)
        }

        return (stubNetworking, chatkit, (expectation.result?.0)!)
    }
    
}
