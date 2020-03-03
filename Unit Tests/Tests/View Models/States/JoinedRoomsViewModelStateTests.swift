import XCTest
@testable import PusherChatkit

class JoinedRoomsViewModelStateTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstRoom: Room!
    var secondRoom: Room!
    var thirdRoom: Room!
    var fourthRoom: Room!
    var fifthRoom: Room!
    var sixthRoom: Room!
    
    var firstRooms: [Room]!
    var secondRooms: [Room]!
    
    var firstChangeReason: JoinedRoomsViewModel.ChangeReason!
    var secondChangeReason: JoinedRoomsViewModel.ChangeReason!
    
    var firstError: Error!
    var secondError: Error!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        self.firstRoom = Room(identifier: "first-room-identifier",
                              name: nil,
                              isPrivate: false,
                              unreadCount: 10,
                              lastMessageAt: nil,
                              customData: nil,
                              createdAt: Date(timeIntervalSince1970: 60),
                              updatedAt: .distantPast)
        
        self.secondRoom = Room(identifier: "second-room-identifier",
                               name: nil,
                               isPrivate: false,
                               unreadCount: 10,
                               lastMessageAt: nil,
                               customData: nil,
                               createdAt: Date(timeIntervalSince1970: 50),
                               updatedAt: .distantPast)
        
        self.thirdRoom = Room(identifier: "third-room-identifier",
                              name: nil,
                              isPrivate: false,
                              unreadCount: 10,
                              lastMessageAt: nil,
                              customData: nil,
                              createdAt: Date(timeIntervalSince1970: 40),
                              updatedAt: .distantPast)
        
        self.fourthRoom = Room(identifier: "fourth-room-identifier",
                               name: nil,
                               isPrivate: false,
                               unreadCount: 10,
                               lastMessageAt: Date(timeIntervalSince1970: 30),
                               customData: nil,
                               createdAt: Date(timeIntervalSince1970: 30),
                               updatedAt: .distantPast)
        
        self.fifthRoom = Room(identifier: "fourth-room-identifier",
                              name: nil,
                              isPrivate: false,
                              unreadCount: 10,
                              lastMessageAt: Date(timeIntervalSince1970: 20),
                              customData: nil,
                              createdAt: Date(timeIntervalSince1970: 20),
                              updatedAt: .distantPast)
        
        self.sixthRoom = Room(identifier: "fourth-room-identifier",
                              name: nil,
                              isPrivate: false,
                              unreadCount: 10,
                              lastMessageAt: Date(timeIntervalSince1970: 10),
                              customData: nil,
                              createdAt: Date(timeIntervalSince1970: 10),
                              updatedAt: .distantPast)
        
        let firstPosition = 0
        let secondPosition = 1
        
        self.firstRooms = [self.firstRoom]
        self.secondRooms = [self.secondRoom]
        
        self.firstChangeReason = .itemInserted(position: firstPosition)
        self.firstChangeReason = .itemMoved(fromPosition: firstPosition, toPosition: secondPosition)
        
        self.firstError = NetworkingError.disconnected
        self.secondError = NetworkingError.invalidEvent
    }
    
    // MARK: - Tests
    
    func test_init_withInitializingState_shouldReturnInitializingStateWithCorrectError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryState: JoinedRoomsRepository.State = .initializing(error: self.firstError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.State = .initializing(error: self.firstError)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withConnectedState_shouldReturnConnectedStateWithCorrectRoomsAndChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryState: JoinedRoomsRepository.State = .connected(rooms: Set(self.firstRooms), changeReason: nil)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: nil)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withDegradedState_shouldReturnDegradedStateWithCorrectRoomsAndErrorAndChangeReason() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryState: JoinedRoomsRepository.State = .degraded(rooms: Set(self.firstRooms), error: self.firstError, changeReason: nil)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: nil)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withClosedState_shouldReturnClosedStateWithCorrectError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryState: JoinedRoomsRepository.State = .closed(error: self.firstError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.State = .closed(error: self.firstError)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRooms_shouldReturnStateWithRoomsSortedAccordingToLastMessageAt() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let rooms: Set<Room> = [
            self.sixthRoom,
            self.fourthRoom,
            self.fifthRoom
        ]
        let repositoryState: JoinedRoomsRepository.State = .connected(rooms: rooms, changeReason: nil)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedRooms: [Room] = [
            self.fourthRoom,
            self.fifthRoom,
            self.sixthRoom
        ]
        let expectedValue: JoinedRoomsViewModel.State = .connected(rooms: expectedRooms, changeReason: nil)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRooms_shouldReturnStateWithRoomsSortedAccordingToCreatedAt() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let rooms: Set<Room> = [
            self.secondRoom,
            self.firstRoom,
            self.thirdRoom
        ]
        let repositoryState: JoinedRoomsRepository.State = .connected(rooms: rooms, changeReason: nil)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedRooms: [Room] = [
            self.firstRoom,
            self.secondRoom,
            self.thirdRoom
        ]
        let expectedValue: JoinedRoomsViewModel.State = .connected(rooms: expectedRooms, changeReason: nil)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRooms_shouldReturnStateWithRoomsWithoutLastMessageAtSortedAboveRoomsWithLastMessageAt() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let rooms: Set<Room> = [
            self.fifthRoom,
            self.secondRoom,
            self.fourthRoom,
            self.sixthRoom,
            self.firstRoom,
            self.thirdRoom
        ]
        let repositoryState: JoinedRoomsRepository.State = .connected(rooms: rooms, changeReason: nil)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.State(repositoryState: repositoryState, previousRooms: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedRooms: [Room] = [
            self.firstRoom,
            self.secondRoom,
            self.thirdRoom,
            self.fourthRoom,
            self.fifthRoom,
            self.sixthRoom
        ]
        let expectedValue: JoinedRoomsViewModel.State = .connected(rooms: expectedRooms, changeReason: nil)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_equality_withDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initializingState: JoinedRoomsViewModel.State = .initializing(error: self.firstError)
        let connectedState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let degradedState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let closedState: JoinedRoomsViewModel.State = .closed(error: self.firstError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initializingConnectedResult = initializingState == connectedState
        let initializingDegradedResult = initializingState == degradedState
        let initializingClosedResult = initializingState == closedState
        
        let connectedDegradedResult = connectedState == degradedState
        let connectedClosedResult = connectedState == closedState
        
        let degradedClosedResult = degradedState == closedState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(initializingConnectedResult)
        XCTAssertFalse(initializingDegradedResult)
        XCTAssertFalse(initializingClosedResult)
        
        XCTAssertFalse(connectedDegradedResult)
        XCTAssertFalse(connectedClosedResult)
        
        XCTAssertFalse(degradedClosedResult)
    }
    
    func test_equality_withInitializingAndInitializingHavingEqualErrors_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .initializing(error: self.firstError)
        let secondState: JoinedRoomsViewModel.State = .initializing(error: self.firstError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withInitializingAndInitializingHavingDifferentErrors_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .initializing(error: self.firstError)
        let secondState: JoinedRoomsViewModel.State = .initializing(error: self.secondError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withClosedAndClosedHavingEqualErrors_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .closed(error: self.firstError)
        let secondState: JoinedRoomsViewModel.State = .closed(error: self.firstError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withClosedAndClosedHavingDifferentErrors_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .closed(error: self.firstError)
        let secondState: JoinedRoomsViewModel.State = .closed(error: self.secondError)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withConnectedAndConnectedHavingEqualRoomsAndChangeReasons_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withConnectedAndConnectedHavingDifferentRoomsAndEqualChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .connected(rooms: self.secondRooms, changeReason: self.firstChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withConnectedAndConnectedHavingEqualRoomsAndDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .connected(rooms: self.firstRooms, changeReason: self.secondChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withDegradedAndDegradedHavingEqualRoomsAndErrorsAndChangeReasons_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withDegradedAndDegradedHavingDifferentRoomsAndEqualErrorsAndEqualChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .degraded(rooms: self.secondRooms, error: self.firstError, changeReason: self.firstChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withDegradedAndDegradedHavingEqualRoomsAndDifferentErrorsAndEqualChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.secondError, changeReason: self.firstChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withDegradedAndDegradedHavingEqualRoomsAndEqualErrorsAndDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsViewModel.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.secondChangeReason)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstState == secondState
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
}
