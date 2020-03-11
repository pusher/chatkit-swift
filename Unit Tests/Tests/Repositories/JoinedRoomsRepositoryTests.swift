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
        
        let subscriptionTypeToReturn: SubscriptionType = .user
        let connectionStateToReturn: ConnectionState = .initializing(error: nil)
        
        let stateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionTypeToReturn : connectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionTypeToReturn,
                                                              connectionState_toReturn: connectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        
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
        
        let subscriptionTypeToReturn: SubscriptionType = .user
        let connectionStateToReturn: ConnectionState = .connected
        
        let stateToReturn = VersionedState(
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
                    subscriptionTypeToReturn : connectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionTypeToReturn,
                                                              connectionState_toReturn: connectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformState_expectedSetCallCount: 1,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        
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
        
        let subscriptionTypeToReturn: SubscriptionType = .user
        let errorToReturn = FakeError.firstError
        let connectionStateToReturn: ConnectionState = .degraded(error: errorToReturn)
        
        let stateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionTypeToReturn : connectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionTypeToReturn,
                                                              connectionState_toReturn: connectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .degraded(rooms: [], error: errorToReturn, changeReason: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_init_withClosedStatePresentInAuxiliaryState_returnsClosedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionTypeToReturn: SubscriptionType = .user
        let connectionStateToReturn: ConnectionState = .closed(error: nil)
        
        let stateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionTypeToReturn : connectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionTypeToReturn,
                                                              connectionState_toReturn: connectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        
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
        
        let subscriptionTypeToReturn: SubscriptionType = .user
        let connectionStateToReturn: ConnectionState = .connected
        
        let stubBuffer = StubBuffer(currentState_toReturn: nil, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: subscriptionTypeToReturn,
                                                              connectionState_toReturn: connectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        
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
        
        let initialSubscriptionTypeToReturn: SubscriptionType = .user
        let initialConnectionStateToReturn: ConnectionState = .initializing(error: nil)
        
        let initialStateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    initialSubscriptionTypeToReturn : initialConnectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let modifiedConnectionStateToReturn: ConnectionState = .closed(error: nil)
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialStateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: initialSubscriptionTypeToReturn,
                                                              connectionState_toReturn: initialConnectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        let expectation = XCTestExpectation(description: "Delegate called")
        
        XCTAssertEqual(sut.state, .initializing(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubConnectivityMonitor.report(modifiedConnectionStateToReturn)
        
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
        
        let initialSubscriptionTypeToReturn: SubscriptionType = .user
        let initialConnectionStateToReturn: ConnectionState = .initializing(error: nil)
        
        let initialStateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    initialSubscriptionTypeToReturn : initialConnectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let modifiedConnectionStateToReturn: ConnectionState = .closed(error: nil)
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialStateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: initialSubscriptionTypeToReturn,
                                                              connectionState_toReturn: initialConnectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state, .initializing(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubConnectivityMonitor.report(modifiedConnectionStateToReturn)
        
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
        
        let initialSubscriptionTypeToReturn: SubscriptionType = .user
        let initialConnectionStateToReturn: ConnectionState = .connected
        
        let initialStateToReturn = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    initialSubscriptionTypeToReturn : initialConnectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let modifiedStateToReturn = VersionedState(
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
                    initialSubscriptionTypeToReturn : initialConnectionStateToReturn
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubBuffer = StubBuffer(currentState_toReturn: initialStateToReturn, delegate_expectedSetCallCount: 1)
        
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: initialSubscriptionTypeToReturn,
                                                              connectionState_toReturn: initialConnectionStateToReturn,
                                                              delegate_expectedSetCallCount: 1)
        
        let stubTransformer = StubTransformer(room_toReturn: self.room,
                                              transformState_expectedSetCallCount: 1,
                                              transformCurrentStatePreviousState_expectedSetCallCount: 2)
        
        let stubDelegate = StubJoinedRoomsRepositoryDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let sut = JoinedRoomsRepository(buffer: stubBuffer, connectivityMonitor: stubConnectivityMonitor, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state,
                       .connected(rooms: [], changeReason: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubBuffer.report(modifiedStateToReturn)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsRepository.State = .connected(rooms: [self.room], changeReason: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
}
