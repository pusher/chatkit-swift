import XCTest
@testable import PusherChatkit

class ConcreteTransformerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_transform_withRoomState_mapsStateToRoom() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = RoomState(
            identifier: "test-identifier",
            name: "test-name",
            isPrivate: true,
            pushNotificationTitle: "test-push-notification-title",
            customData: [
                "test-key" : "test-value"
            ],
            lastMessageAt: .distantPast,
            readSummary: ReadSummaryState(
                unreadCount: 10
            ),
            createdAt: .distantPast,
            updatedAt: .distantFuture
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let room = sut.transform(state: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(room.identifier, "test-identifier")
        XCTAssertEqual(room.name, "test-name")
        XCTAssertTrue(room.isPrivate)
        XCTAssertEqual(room.unreadCount, 10)
        XCTAssertEqual(room.lastMessageAt, .distantPast)
        XCTAssertEqual(room.customData?.count, 1)
        XCTAssertEqual(room.customData?["test-key"] as? String, "test-value")
        XCTAssertEqual(room.createdAt, .distantPast)
        XCTAssertEqual(room.updatedAt, .distantFuture)
    }
    
    func test_transform_withCurrentStateHavingSignatureThatDoNotContainRoomIdentifier_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingAddedToRoomSignatureThatPointsToExistingRoom_mapsToAddedToRoomChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .addedToRoom(roomIdentifier: roomIdentifier)
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(
            room: Room(
                identifier: roomIdentifier,
                name: "room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            )
        )
        
        XCTAssertEqual(changeReason, expectedChangeReason)
    }
    
    func test_transform_withCurrentStateHavingAddedToRoomSignatureThatPointsToNonExistingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .addedToRoom(roomIdentifier: roomIdentifier)
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingRemovedFromRoomSignatureThatPointsToExistingRoom_mapsToRemovedFromRoomChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .removedFromRoom(roomIdentifier: roomIdentifier)
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(
            room: Room(
                identifier: roomIdentifier,
                name: "room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            )
        )
        
        XCTAssertEqual(changeReason, expectedChangeReason)
    }
    
    func test_transform_withCurrentStateHavingRemovedFromRoomSignatureThatPointsToNonExistingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .removedFromRoom(roomIdentifier: roomIdentifier)
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingRoomUpdatedSignatureThatPointsToExistingRoomInCurrentStateAndPreviousState_mapsToRoomUpdatedChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "new-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .roomUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "old-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(
            updatedRoom: Room(
                identifier: roomIdentifier,
                name: "new-room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            ),
            previousValue: Room(
                identifier: roomIdentifier,
                name: "old-room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            )
        )
        
        XCTAssertEqual(changeReason, expectedChangeReason)
    }
    
    func test_transform_withCurrentStateHavingRoomUpdatedSignatureThatPointsToNonExistingRoomInCurrentStateAndExistingRoomInPreviousState_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .roomUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "old-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingRoomUpdatedSignatureThatPointsToExistingRoomInCurrentStateAndNonExistingRoomInPreviousState_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "new-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .roomUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingRoomDeletedSignatureThatPointsToExistingRoom_mapsToRoomDeletedChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 2,
            signature: .roomDeleted(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(
            room: Room(
                identifier: roomIdentifier,
                name: "room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            )
        )
        
        XCTAssertEqual(changeReason, expectedChangeReason)
    }
    
    func test_transform_withCurrentStateHavingRoomDeletedSignatureThatPointsToNonExistingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .roomDeleted(roomIdentifier: roomIdentifier)
        )
        
        let previousState: VersionedState? = nil
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingReadStateUpdatedSignatureThatPointsToExistingRoomInCurrentStateAndPreviousState_mapsToReadStateUpdatedChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "new-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .readStateUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "old-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(
            updatedRoom: Room(
                identifier: roomIdentifier,
                name: "new-room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            ),
            previousValue: Room(
                identifier: roomIdentifier,
                name: "old-room-name",
                isPrivate: false,
                unreadCount: 10,
                lastMessageAt: nil,
                customData: nil,
                createdAt: .distantPast,
                updatedAt: .distantPast
            )
        )
        
        XCTAssertEqual(changeReason, expectedChangeReason)
    }
    
    func test_transform_withCurrentStateHavingReadStateUpdatedSignatureThatPointsToNonExistingRoomInCurrentStateAndExistingRoomInPreviousState_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .readStateUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "old-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
    func test_transform_withCurrentStateHavingReadStateUpdatedSignatureThatPointsToExistingRoomInCurrentStateAndNonExistingRoomInPreviousState_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let currentState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: roomIdentifier,
                            name: "new-room-name",
                            isPrivate: false,
                            pushNotificationTitle: nil,
                            customData: nil,
                            lastMessageAt: nil,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantPast
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .readStateUpdated(roomIdentifier: roomIdentifier)
        )
        
        let previousState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let sut = ConcreteTransformer()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let changeReason = sut.transform(currentState: currentState, previousState: previousState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(changeReason)
    }
    
}
