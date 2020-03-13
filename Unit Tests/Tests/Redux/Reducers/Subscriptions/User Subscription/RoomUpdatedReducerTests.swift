import XCTest
import TestUtilities
@testable import PusherChatkit

class RoomUpdatedReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withRoomUpdatedAction_returnsStateFromDedicatedReducer() {
        
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
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "second-room",
                    name: "Second Room",
                    isPrivate: true,
                    pushNotificationTitleOverride: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast,
                    deletedAt: .distantPast
                )
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
                ),
                RoomState(
                    identifier: "second-room",
                    name: "Second Room",
                    isPrivate: true,
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
        
        let outputState = Reducer.UserSubscription.RoomUpdated.reduce(action: action, state: inputState, dependencies: dependencies)
        
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
