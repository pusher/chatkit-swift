import XCTest
@testable import PusherChatkit

class BundleExtensionsTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCurrentBundle() {
        XCTAssertNotNil(Bundle.current)
    }
    
    func testCurrentBundleShouldPointToChatkitFramework() {
        let bundle = Bundle.current
        
        XCTAssertEqual(bundle, Bundle(for: Chatkit.self))
    }
    
}
