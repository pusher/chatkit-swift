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

    enum SetupError: String, Error {
        case joinedRoomsRepositoryNotInitialised = "joinedRoomsRepository was not initialised"
    }
    
    // TODO: `JoinedRoomsTransformer`
    // Remove this method & returning of `dependencies` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_ChatKitInitialised_withDependencies(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, Dependencies) {
        
        let stubNetworking = StubNetworking(file: file, line: line)
        let dependencies = ConcreteDependencies(instanceWrapperFactory: stubNetworking)
        
        let chatkit = try Chatkit(dependencies: dependencies)
        
        return (stubNetworking, chatkit, dependencies)
    }
        
    func setUp_ChatKitInitialised(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit) {
        
        let (stubNetworking, chatkit, _) = try setUp_ChatKitInitialised_withDependencies(file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
}
