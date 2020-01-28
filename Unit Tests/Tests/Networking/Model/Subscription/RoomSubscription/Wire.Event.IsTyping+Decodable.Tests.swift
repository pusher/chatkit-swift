import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class WireEventIsTypingDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "user_id": "alice",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.IsTyping(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.userIdentifier, "alice")
        }
    }
    
    func test_init_userIdentifierMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.IsTyping(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_id\""])
    }
    
    func test_init_userIdentifierNull_throws() {
        
        let jsonData = """
        {
            "user_id": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.IsTyping(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_userIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "user_id": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.IsTyping(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
}
