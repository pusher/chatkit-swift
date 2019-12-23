import XCTest
@testable import PusherChatkit

class DateFormatterExtensionsTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_date_formatMissingMilliseconds_noProblem() {
        let dateAsString = "2017-11-29T16:59:55Z"
        
        let date = DateFormatter.date(fromISO8601String: dateAsString)
        
        XCTAssertNotNil(date) { date in
            print(date)
        }
    }
    
    func test_date_formatImpreciseMilliseconds_noProblem() {
        let dateAsString = "2017-03-23T11:36:42.399Z"
        
        let date = DateFormatter.date(fromISO8601String: dateAsString)
        
        XCTAssertNotNil(date) { date in
            print(date)
        }
    }
    
    func test_date_formatPreciseMilliseconds_noProblem() {
        let dateAsString = "2017-03-23T11:36:42.123456789012345678901234567890Z"
        
        let date = DateFormatter.date(fromISO8601String: dateAsString)
        
        XCTAssertNotNil(date) { date in
            print(date)
        }
    }
}
