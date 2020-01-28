import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class WireCursorDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Cursor(from: jsonData.jsonDecoder())) { cursor in
            XCTAssertEqual(cursor.roomIdentifier, "ac43dfef")
            XCTAssertEqual(cursor.userIdentifier, "alice")
            XCTAssertEqual(cursor.cursorType, .read)
            XCTAssertEqual(cursor.position, 43398)
            XCTAssertEqual(cursor.updatedAt, Date(fromISO8601String: "2017-04-13T14:10:04Z"))
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_id\""])
    }
    
    func test_init_userIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": null,
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_userIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": 123,
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_cursorTypeMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"cursor_type\""])
    }
    
    func test_init_cursorTypeNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": null,
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"cursor_type\"",
                                          "Expected Int but found null value instead."])
    }
    
    func test_init_cursorTypeInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": "not an int",
            "position": 43398,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"cursor_type\"",
                                          "Expected to decode Int but found a string/data instead."])
    }
    
    func test_init_positionMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"position\""])
    }
    
    func test_init_positionNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": null,
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"position\"",
                                          "Expected Int64 value but found null instead."])
    }
    
    func test_init_positionInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": "not an int",
            "updated_at": "2017-04-13T14:10:04Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"position\"",
                                          "Expected to decode Int64 but found a string/data instead."])
    }
    
    func test_init_updatedAtMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"updated_at\""])
    }
    
    func test_init_updatedAtNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"updated_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_updatedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"updated_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_updatedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
            "cursor_type": 0,
            "position": 43398,
            "updated_at": "not a date",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Cursor(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"updated_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
}
