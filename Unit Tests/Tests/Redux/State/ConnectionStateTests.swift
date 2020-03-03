import XCTest
@testable import PusherChatkit

class ConnectionStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_alwaysReturnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: ConnectionState = .connected
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_supplement_alwaysReturnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: ConnectionState = .degraded(error: NetworkingError.disconnected)
        
        let supplementalState: ConnectionState = .degraded(error: NetworkingError.invalidEvent)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, state)
    }
    
    func test_hashValue_withDifferentConnectionStates_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let error: NetworkingError = .disconnected
        
        let initializingConnectionState: ConnectionState = .initializing(error: error)
        let connectedConnectionState: ConnectionState = .connected
        let degradedConnectionState: ConnectionState = .degraded(error: error)
        let closedConnectionState: ConnectionState = .closed(error: error)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initializingHashValue = initializingConnectionState.hashValue
        let connectedHashValue = connectedConnectionState.hashValue
        let degradedHashValue = degradedConnectionState.hashValue
        let closedHashValue = closedConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(initializingHashValue, connectedHashValue)
        XCTAssertNotEqual(initializingHashValue, degradedHashValue)
        XCTAssertNotEqual(initializingHashValue, closedHashValue)
        
        XCTAssertNotEqual(connectedHashValue, degradedHashValue)
        XCTAssertNotEqual(connectedHashValue, closedHashValue)
        
        XCTAssertNotEqual(degradedHashValue, closedHashValue)
    }
    
    func test_hashValue_withInitializingAndInitializingHavingEqualErrors_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .initializing(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .initializing(error: NetworkingError.disconnected)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withInitializingAndInitializingHavingDifferentErrors_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .initializing(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .initializing(error: NetworkingError.invalidEvent)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withConnectedAndConnected_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .connected
        let secondConnectionState: ConnectionState = .connected
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withDegradedAndDegradedHavingEqualErrors_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .degraded(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .degraded(error: NetworkingError.disconnected)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withDegradedAndDegradedHavingDifferentErrors_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .degraded(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .degraded(error: NetworkingError.invalidEvent)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withClosedAndClosedHavingEqualErrors_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .closed(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .closed(error: NetworkingError.disconnected)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withClosedAndClosedHavingDifferentErrors_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstConnectionState: ConnectionState = .closed(error: NetworkingError.disconnected)
        let secondConnectionState: ConnectionState = .closed(error: NetworkingError.invalidEvent)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstConnectionState.hashValue
        let secondHashValue = secondConnectionState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
}
