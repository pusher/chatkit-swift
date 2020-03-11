import XCTest
import TestUtilities
@testable import PusherChatkit

class JoinedRoomsRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    let room = Room(identifier: "room-identifier",
                    name: "room-name",
                    isPrivate: false,
                    unreadCount: 10,
                    lastMessageAt: nil,
                    customData: nil,
                    createdAt: .distantPast,
                    updatedAt: .distantPast)
    
    // MARK: - Tests
    
    func test_init_withInitializingStatePresentInAuxiliaryState_returnsInitializingState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .initializing(error: nil)
        
        let state = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType: initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: state, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .initializing(error: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_init_withConnectedStatePresentInAuxiliaryState_returnsConnectedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .connected
        
        let initialState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "room-identifier",
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
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialState, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformState_expectedSetCallCount: 1,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .connected(rooms: [self.room], changeReason: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_init_withDegradedStatePresentInAuxiliaryState_returnsdegradedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let error = FakeError.firstError
        let initialConnectionState: ConnectionState = .degraded(error: error)
        
        let state = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: state, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .degraded(rooms: [], error: error, changeReason: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_init_withClosedStatePresentInAuxiliaryState_returnsClosedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .closed(error: nil)
        
        let state = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: state, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .closed(error: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_init_withInitialStateBuffered_returnsInitializingState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .connected
        
        let stubBuffer = StubBuffer(currentState_toReturn: nil, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .initializing(error: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_delegate_shouldReportChangedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .initializing(error: nil)
        
        let state = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let modifiedConnectionState: ConnectionState = .closed(error: nil)
        
        let stubBuffer = StubBuffer(currentState_toReturn: state, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        sut.delegate = stubDelegate
        
        let expectation = XCTestExpectation(description: "Delegate called")
        
        XCTAssertEqual(sut.state, .initializing(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubConnectivityMonitor.report(modifiedConnectionState)
        
        expectation.fulfill(after: 0.1)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: 1.0)
        
        let expectedState: JoinedRoomsRepository.State = .closed(error: nil)
        
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_state_shouldChangeWhenNewStateIsReportedByConnectivityMonitor() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .initializing(error: nil)
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let modifiedConnectionState: ConnectionState = .closed(error: nil)
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialState, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state, .initializing(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubConnectivityMonitor.report(modifiedConnectionState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .closed(error: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_state_shouldChangeWhenNewStateIsReportedByBuffer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let initialConnectionState: ConnectionState = .connected
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : initialConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        
        let modifiedConnectionState: ConnectionState = .connected
        let modifiedState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "room-identifier",
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
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : modifiedConnectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialState, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionType,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformState_expectedSetCallCount: 1,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer,
                                        connectivityMonitor: stubConnectivityMonitor,
                                        connectionState: initialConnectionState,
                                        dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state,
                       .connected(rooms: [], changeReason: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubBuffer.report(modifiedState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .connected(rooms: [self.room], changeReason: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
}
