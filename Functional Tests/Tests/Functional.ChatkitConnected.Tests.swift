import TestUtilities
import XCTest
@testable import PusherChatkit

class Functional_ChatkitConnected_Tests: XCTestCase {
    
    func test_chatkitConnect_returnsSuccessDoesNotAttemptReconnectionAndRemainsConnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (_, chatkit) = try setUp_ChatKitConnected(initialState: initialStateJsonData)
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = XCTestExpectation.Chatkit.connect
            chatkit.connect(completionHandler: expectation.handler)
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            // `connect` is idempotent - chatkit remains connected, no reconnection is attempted and no error is returned,
            XCTAssertExpectationFulfilledWithResult(expectation, nil)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
        }())
    }
    
    func test_chatkitDisconnect_chatkitBecomesDisconnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, chatkit) = try setUp_ChatKitConnected(initialState: initialStateJsonData)
            
            stubNetworking.stubSubscriptionEnd(.user)
            
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
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (_, chatkit) = try setUp_ChatKitConnected(initialState: initialStateJsonData)
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let joinedRoomsRepository = chatkit.makeJoinedRoomsRepository()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            if case let .connected(rooms, changeReason) = joinedRoomsRepository.state {
                XCTAssertEqual(rooms.count, 0)
                XCTAssertEqual(changeReason, nil)
            } else {
                XCTFail("Unexpected state - \(joinedRoomsRepository.state)")
            }
            
        }())
    }
    
    func test_storeRegister_listenerReceivesStateOnSubscriptionEvents() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, _, store) = try setUp_ChatKitConnected_withStore(initialState: initialStateJsonData)
            
            let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 2)
            
            XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
            
            var latestState: VersionedState?
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            latestState = store.register(stubStoreListener)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            XCTAssertEqual(latestState?.chatState.joinedRooms.elements.count, 0)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/

            let addedToRoomEventJsonData = """
            {
                "event_name": "added_to_room",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "room": {
                        "id": "ac43dfef",
                        "name": "Chatkit chat",
                        "private": false,
                        "created_at": "2017-03-23T11:36:42Z",
                        "updated_at": "2017-07-28T22:19:32Z",
                    },
                    "membership": {
                        "room_id": "ac43dfef",
                        "user_ids": ["alice", "carol"],
                    },
                    "read_state": {
                        "room_id": "ac43dfef",
                        "unread_count": 3,
                        "cursor": null,
                    },
                },
            }
            """.toJsonData()
                    
            stubNetworking.fireSubscriptionEvent(.user, addedToRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            latestState = stubStoreListener.didUpdateState_stateLastReceived
            XCTAssertEqual(latestState?.chatState.joinedRooms.elements.count, 1)
            XCTAssertNotNil(latestState?.chatState.joinedRooms.elements["ac43dfef"])
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
            
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
            
            latestState = stubStoreListener.didUpdateState_stateLastReceived
            XCTAssertEqual(latestState?.chatState.joinedRooms.elements.count, 0)
            XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 2)

        }())
        
    }
    
}
    
