import XCTest
import TestUtilities
@testable import PusherChatkit

class JoinedRoomsRepositoryStateTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstRooms: Set<Room>!
    var secondRooms: Set<Room>!
    
    var firstChangeReason: JoinedRoomsRepository.ChangeReason!
    var secondChangeReason: JoinedRoomsRepository.ChangeReason!
    
    var firstError: Error!
    var secondError: Error!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        let firstRoom = Room(identifier: "first-room-identifier",
                             name: nil,
                             isPrivate: false,
                             unreadCount: 10,
                             lastMessageAt: nil,
                             customData: nil,
                             createdAt: .distantPast,
                             updatedAt: .distantPast)
        
        let secondRoom = Room(identifier: "second-room-identifier",
                              name: nil,
                              isPrivate: false,
                              unreadCount: 10,
                              lastMessageAt: nil,
                              customData: nil,
                              createdAt: .distantPast,
                              updatedAt: .distantPast)
        
        self.firstRooms = [firstRoom]
        self.secondRooms = [secondRoom]
        
        self.firstChangeReason = .addedToRoom(room: firstRoom)
        self.firstChangeReason = .removedFromRoom(room: secondRoom)
        
        self.firstError = FakeError.firstError
        self.secondError = FakeError.secondError
    }
    
    // MARK: - Tests
    
    func test_equality_withDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initializingState: JoinedRoomsRepository.State = .initializing(error: self.firstError)
        let connectedState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let degradedState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let closedState: JoinedRoomsRepository.State = .closed(error: self.firstError)
        
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
        
        let firstState: JoinedRoomsRepository.State = .initializing(error: self.firstError)
        let secondState: JoinedRoomsRepository.State = .initializing(error: self.firstError)
        
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
        
        let firstState: JoinedRoomsRepository.State = .initializing(error: self.firstError)
        let secondState: JoinedRoomsRepository.State = .initializing(error: self.secondError)
        
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
        
        let firstState: JoinedRoomsRepository.State = .closed(error: self.firstError)
        let secondState: JoinedRoomsRepository.State = .closed(error: self.firstError)
        
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
        
        let firstState: JoinedRoomsRepository.State = .closed(error: self.firstError)
        let secondState: JoinedRoomsRepository.State = .closed(error: self.secondError)
        
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
        
        let firstState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .connected(rooms: self.secondRooms, changeReason: self.firstChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .connected(rooms: self.firstRooms, changeReason: self.secondChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .degraded(rooms: self.secondRooms, error: self.firstError, changeReason: self.firstChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.secondError, changeReason: self.firstChangeReason)
        
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
        
        let firstState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.firstChangeReason)
        let secondState: JoinedRoomsRepository.State = .degraded(rooms: self.firstRooms, error: self.firstError, changeReason: self.secondChangeReason)
        
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
