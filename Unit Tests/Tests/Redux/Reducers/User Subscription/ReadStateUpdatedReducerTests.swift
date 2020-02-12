import XCTest
import TestUtilities
@testable import PusherChatkit

class ReadStateUpdatedReducerTests: XCTestCase {
    
    // MARK: - Properties
    
    let testUser = UserState.populated(
        identifier: "alice",
        name: "Alice A"
    )
    
    // MARK: - Tests
    
    func test_reduce_withCurrentStateAndReadStateUpdatedActionForExistingRoom_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: "nil",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 10
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: "nil",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 0
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            )
        )
        
        let action = ReadStateUpdatedAction(
            event: Wire.Event.ReadStateUpdated(
                readState: Wire.ReadState(
                    roomIdentifier: "second-room",
                    unreadCount: 20,
                    cursor: nil)
            )
        )
        
        let reducer_stateToReturn = RoomListState(
            rooms: [
                "first-room" : RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 10
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 20
                    ),
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
        
        let outputState = Reducer.UserSubscription.ReadStateUpdated.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: "nil",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 10
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: "nil",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 20
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            )
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(stubReducer.reduce_actualCallCount, 1)
    }
    
}
