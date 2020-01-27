import XCTest
@testable import PusherChatkit

class PresenceStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldCreateOnlinePresenceStateForOnlineString() {
        let presenceState = PresenceState(state: "online")
        
        XCTAssertEqual(presenceState, PresenceState.online)
    }
    
    func testShouldCreateOfflinePresenceStateForOfflineString() {
        let presenceState = PresenceState(state: "offline")
        
        XCTAssertEqual(presenceState, PresenceState.offline)
    }
    
    func testShouldCreateUnknownPresenceStateForRandomString() {
        let presenceState = PresenceState(state: "qwerty")
        
        XCTAssertEqual(presenceState, PresenceState.unknown)
    }
    
    func testShouldCreateUnknownPresenceStateForNil() {
        let presenceState = PresenceState(state: nil)
        
        XCTAssertEqual(presenceState, PresenceState.unknown)
    }
    
    func testShouldUseCaseInsensitiveComparisonWhenCreatingPresenceStateFromString() {
        let presenceState = PresenceState(state: "OnLiNe")
        
        XCTAssertEqual(presenceState, PresenceState.online)
    }
    
}
