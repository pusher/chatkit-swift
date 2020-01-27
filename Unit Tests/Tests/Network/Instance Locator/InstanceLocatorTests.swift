import XCTest
@testable import PusherChatkit

class InstanceLocatorTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldInstantiateInstanceLocatorWithCorrectValues() {
        XCTAssertNoThrow(try InstanceLocator(Networking.testInstanceLocator)) { instanceLocator in
            XCTAssertEqual(instanceLocator.region, "instance")
            XCTAssertEqual(instanceLocator.identifier, "locator")
            XCTAssertEqual(instanceLocator.version, "test")
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooFewComponents() {
        XCTAssertThrowsError(try InstanceLocator("invalid:locator"), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooManyComponents() {
        XCTAssertThrowsError(try InstanceLocator("invalid:test:instance:locator"), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
        
}
