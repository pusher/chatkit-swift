import XCTest
@testable import PusherChatkit

class WireCursorTypeDecodableTests: XCTestCase {
    
    func test_init_validValue_noProblem() {
        
        let jsonData = """
        0
        """.toJsonData(validate: false)
        
        XCTAssertNoThrow(try Wire.CursorType(from: jsonData.jsonDecoder())) { cursorType in
            XCTAssertEqual(cursorType, .read)
        }
    }
    
    func test_init_invalidValue_throws() {
        
        let jsonData = """
        1
        """.toJsonData(validate: false)
        
        XCTAssertThrowsError(try Wire.CursorType(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Cannot initialize CursorType from invalid Int value 1"])
    }
    
    func test_init_invalidType_throws() {
        
        let jsonData = """
        "not an int"
        """.toJsonData(validate: false)
        
        XCTAssertThrowsError(try Wire.CursorType(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "Expected to decode Int but found a string/data instead."])
    }
    
}
