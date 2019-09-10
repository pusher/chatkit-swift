import XCTest
@testable import PusherChatkit

class EventNameTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCorrectValueForInitialStateEventName() {
        XCTAssertEqual(Event.Name.initialState.rawValue, "initial_state")
    }
    
}
