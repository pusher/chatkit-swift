import TestUtilities
import XCTest
@testable import PusherChatkit

extension Chatkit {
    // TODO: these functions exists just to make things compile for now
    func joinRoom(id roomIdentifier: String, handler: (Result<Void, Error>) -> Void) {}
}

extension XCTestExpectation.Chatkit {
    
    static let joinRoom: XCTestExpectation.Expectation<Result<Void, Error>> =
        .init(functionName: "joinRoom", timeout: 1)
}

class Functional_Sandbox_Tests: XCTestCase {
    
    func test_addedToRoomLocally_success() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateEventJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-03-23T11:36:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z",
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, chatkit, joinedRoomsProvider) = try self.setUp_JoinedRoomsProviderInitialised(initialState: initialStateEventJsonData)
            
            let expectationA = XCTestExpectation.JoinedRoomsProviderDelegate.didJoinRoom
            let stubJoinedRoomsProviderDelegate = StubJoinedRoomsProviderDelegate(onDidJoinRoom: expectationA.handler)
            joinedRoomsProvider.delegate = stubJoinedRoomsProviderDelegate
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let joinRoomJsonData = """
            {
                "id": "cool-room-1",
                "created_by_id": "jean",
                "name": "mycoolroom",
                "private": false,
                "last_message_at": "2017-04-23T11:36:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "member_user_ids": ["ham"]
            }
            """.toJsonData()
            
            stubNetworking.stub("/users/test-user/rooms/test-room/join", joinRoomJsonData)
            
            let expectationB = XCTestExpectation.Chatkit.joinRoom
            chatkit.joinRoom(id: "test-room", handler: expectationB.handler)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            // Wait for two things:
            //  a) The call to `chatkit.joinRoom` to return
            //  b) The delegate's `didJoinRoom` func to fire (to allow time for the joined room to propagate through the state machine)
            wait(for: [expectationA, expectationB], timeout: max(expectationA.timeout, expectationB.timeout))
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 1)
            
        }())
        
    }
}
