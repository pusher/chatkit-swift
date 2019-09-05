import XCTest
import PusherPlatform
@testable import PusherChatkit

class PCBaseClientExtensionsTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldReturnHostForInstanceLocatorWithCorrectFormat() {
        let host = try? PPBaseClient.host(for: Networking.testInstanceLocator)
        
        XCTAssertEqual(host, "instance.pusherplatform.io")
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooFewComponents() {
        XCTAssertThrowsError(try PPBaseClient.host(for: "invalid:locator"), "Failed to catch an error for invalid instance locator.") { error in
            guard let error = error as? NetworkingError else {
                return
            }
            
            XCTAssertEqual(error, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooManyComponents() {
        XCTAssertThrowsError(try PPBaseClient.host(for: "invalid:test:instance:locator"), "Failed to catch an error for invalid instance locator.") { error in
            guard let error = error as? NetworkingError else {
                return
            }
            
            XCTAssertEqual(error, NetworkingError.invalidInstanceLocator)
        }
    }
    
}
