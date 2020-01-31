import TestUtilities
import XCTest
@testable import PusherChatkit

class WireReadStateDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": 3,
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.ReadState(from: jsonData.jsonDecoder())) { readState in
            XCTAssertEqual(readState.roomIdentifier, "ac43dfef")
            XCTAssertEqual(readState.unreadCount, 3)
            XCTAssertEqual(readState.cursor?.roomIdentifier, "ac43dfef")
            XCTAssertEqual(readState.cursor?.userIdentifier, "alice")
            XCTAssertEqual(readState.cursor?.cursorType, .read)
            XCTAssertEqual(readState.cursor?.position, 43398)
            XCTAssertEqual(readState.cursor?.updatedAt, Date(fromISO8601String: "2017-04-13T14:10:04Z"))
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "unread_count": 3,
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "unread_count": 3,
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "unread_count": 3,
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_unreadCountMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"unread_count\""])
    }
    
    func test_init_unreadCountNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": null,
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"unread_count\"",
                                          "Expected UInt64 value but found null instead."])
    }
    
    func test_init_unreadCountInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": "not an int",
            "cursor": {
                "room_id": "ac43dfef",
                "user_id": "alice",
                "cursor_type": 0,
                "position": 43398,
                "updated_at": "2017-04-13T14:10:04Z",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"unread_count\"",
                                          "Expected to decode UInt64 but found a string/data instead."])
    }
    
    func test_init_cursorMissing_noProblem() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": 3,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.ReadState(from: jsonData.jsonDecoder())) { readState in
            XCTAssertEqual(readState.roomIdentifier, "ac43dfef")
            XCTAssertEqual(readState.unreadCount, 3)
            XCTAssertEqual(readState.cursor, nil)
        }
    }
    
    func test_init_cursorNull_noProblem() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": 3,
            "cursor": null,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.ReadState(from: jsonData.jsonDecoder())) { readState in
            XCTAssertEqual(readState.roomIdentifier, "ac43dfef")
            XCTAssertEqual(readState.unreadCount, 3)
            XCTAssertEqual(readState.cursor, nil)
        }
    }
    
    func test_init_cursorInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "unread_count": 3,
            "cursor": "not a cursor"
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"cursor\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
}
