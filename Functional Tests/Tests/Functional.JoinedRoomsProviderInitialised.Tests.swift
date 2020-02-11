import TestUtilities
import XCTest
@testable import PusherChatkit

class Functional_JoinedRoomsProviderInitialised_Tests: XCTestCase {
        
    func test_removedFromRoomRemotely_success() {
        
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
                        "id": "alice",
                        "name": "Alice A",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z",
                    },
                    "rooms": [
                        {
                            "id": "ac43dfef",
                            "name": "Chatkit chat",
                            "created_by_id": "alice",
                            "private": false,
                            "created_at": "2017-03-23T11:36:42Z",
                            "updated_at": "2017-07-28T22:19:32Z",
                        }
                    ],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, _, joinedRoomsProvider) = try setUp_JoinedRoomsProviderInitialised(initialState: initialStateEventJsonData)
            
            let expectation = XCTestExpectation.JoinedRoomsProviderDelegate.didLeaveRoom
            let stubJoinedRoomsProviderDelegate = StubJoinedRoomsProviderDelegate(onDidLeaveRoom: expectation.handler)
            joinedRoomsProvider.delegate = stubJoinedRoomsProviderDelegate
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 1)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let removedFromRoomEventJsonData = """
            {
                "event_name": "removed_from_room",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "room_id": "ac43dfef",
                },
            }
            """.toJsonData()
            stubNetworking.fireSubscriptionEvent(.user, removedFromRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            // Wait for the delegate's `didLeaveRoom` func to fire (to allow time for the joined room to propagate through the state machine)
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 0)
            
        }())
    }

}
