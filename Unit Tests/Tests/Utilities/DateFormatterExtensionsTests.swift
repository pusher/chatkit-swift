import XCTest
@testable import PusherChatkit

class DateFormatterExtensionsTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveDefaultDateFormatter() {
        XCTAssertNotNil(DateFormatter.default)
    }
    
    func testShouldHaveCorrectDateFormat() {
        let dateFormatter = DateFormatter.default
        
        XCTAssertEqual(dateFormatter.dateFormat, "yyyy-MM-dd'T'HH:mm:ssZ")
    }
    
    func testShouldHaveCorrectLocale() {
        let dateFormatter = DateFormatter.default
        
        XCTAssertEqual(dateFormatter.locale, Locale(identifier: "en_US_POSIX"))
    }
    
    func testShouldHaveCorrectTimeZone() {
        let dateFormatter = DateFormatter.default
        
        XCTAssertEqual(dateFormatter.timeZone, TimeZone(abbreviation: "UTC"))
    }
    
}
