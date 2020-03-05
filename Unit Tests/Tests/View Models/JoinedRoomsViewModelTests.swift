import XCTest
import TestUtilities
@testable import PusherChatkit

class JoinedRoomsViewModelTests: XCTestCase {
    
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
    
    func test_init_withJoinedRoomsRepository_shouldSetItselfAsDelegate() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stateToReturn: JoinedRoomsRepository.State = .initializing(error: nil)
        
        let stubJoinedRoomsRepository = StubJoinedRoomsRepository(state_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        _ = JoinedRoomsViewModel(repository: stubJoinedRoomsRepository)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubJoinedRoomsRepository.delegate_actualSetCallCount, 1)
    }
    
    func test_init_withJoinedRoomsRepository_returnsStateMappedFromTheRepository() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stateToReturn: JoinedRoomsRepository.State = .initializing(error: nil)
        
        let stubJoinedRoomsRepository = StubJoinedRoomsRepository(state_toReturn: stateToReturn, delegate_expectedSetCallCount: 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = JoinedRoomsViewModel(repository: stubJoinedRoomsRepository)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsViewModel.State = .initializing(error: nil)
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_delegate_shouldReportChangedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialStateToReturn: JoinedRoomsRepository.State = .initializing(error: nil)
        let modifiedStateToReturn: JoinedRoomsRepository.State = .connected(rooms: [self.room], changeReason: nil)
        
        let stubJoinedRoomsRepository = StubJoinedRoomsRepository(state_toReturn: initialStateToReturn, delegate_expectedSetCallCount: 1)
        let stubDelegate = StubJoinedRoomsViewModelDelegate(didUpdateState_expectedCallCount: 1)
        
        let sut = JoinedRoomsViewModel(repository: stubJoinedRoomsRepository)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state, .initializing(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubJoinedRoomsRepository.report(modifiedStateToReturn)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsViewModel.State = .connected(rooms: [self.room], changeReason: nil)
        
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_state_shouldChangeWhenNewStateIsReportedByJoinedRoomsRepository() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialStateToReturn: JoinedRoomsRepository.State = .connected(rooms: [self.room], changeReason: nil)
        let modifiedStateToReturn: JoinedRoomsRepository.State = .degraded(rooms: [self.room], error: FakeError.firstError, changeReason: nil)
        
        let stubJoinedRoomsRepository = StubJoinedRoomsRepository(state_toReturn: initialStateToReturn, delegate_expectedSetCallCount: 1)
        let stubDelegate = StubJoinedRoomsViewModelDelegate(didUpdateState_expectedCallCount: 1)
        
        let sut = JoinedRoomsViewModel(repository: stubJoinedRoomsRepository)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.state, .connected(rooms: [self.room], changeReason: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubJoinedRoomsRepository.report(modifiedStateToReturn)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: JoinedRoomsViewModel.State = .degraded(rooms: [self.room], error: FakeError.firstError, changeReason: nil)
        
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
}
