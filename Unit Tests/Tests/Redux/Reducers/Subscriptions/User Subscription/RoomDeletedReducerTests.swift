import XCTest
import TestUtilities
@testable import PusherChatkit

class RoomDeletedReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withRoomDeletedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                elements: [
                    RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let action = RoomDeletedAction(
            event: Wire.Event.RoomDeleted(
                roomIdentifier: "second-room"
            )
        )
        
        let reducer_stateToReturn = RoomListState(
            elements: [
                RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: .empty,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let stubReducer = StubReducer<Reducer.Model.RoomList>(reduce_stateToReturn: reducer_stateToReturn, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(roomListReducer: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.RoomDeleted.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: .empty,
            joinedRooms: reducer_stateToReturn,
            users: .empty
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(stubReducer.reduce_actualCallCount, 1)
    }
    
}