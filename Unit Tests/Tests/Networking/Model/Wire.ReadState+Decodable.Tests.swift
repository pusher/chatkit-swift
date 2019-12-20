import XCTest
@testable import PusherChatkit

class WireReadStateDecodableTests: XCTestCase {
        
    let validCursorJsonString = """
    {
      "room_id": "cool-room-1",
      "user_id": "viv",
      "cursor_type": 0,
      "position": 123654,
      "updated_at": "2017-04-13T14:10:04Z"
    }
    """
    
    lazy var validCursor = try! JSONDecoder.default.decode(Wire.Cursor.self, from: validCursorJsonString.toJsonData())
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "cool-room-1",
            "unread_count": 7,
            "cursor": \(validCursorJsonString)
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.ReadState(from: jsonData.jsonDecoder())) { readState in
            XCTAssertEqual(readState.roomIdentifier, "cool-room-1")
            XCTAssertEqual(readState.unreadCount, 7)
            XCTAssertEqual(readState.cursor.roomIdentifier, validCursor.roomIdentifier)
            XCTAssertEqual(readState.cursor.userIdentifier, validCursor.userIdentifier)
            XCTAssertEqual(readState.cursor.cursorType, validCursor.cursorType)
            XCTAssertEqual(readState.cursor.position, validCursor.position)
            XCTAssertEqual(readState.cursor.updatedAt, validCursor.updatedAt)
        }
    }
    
    func test_init_roomIdentiferMissing_throws() {
        
        let jsonData = """
        {
            "unread_count": 7,
            "cursor": \(validCursorJsonString)
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentiferNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "unread_count": 7,
            "cursor": \(validCursorJsonString)
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentiferInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "unread_count": 7,
            "cursor": \(validCursorJsonString)
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
            "room_id": "cool-room-1",
            "cursor": \(validCursorJsonString)
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"unread_count\""])
    }
    
    func test_init_unreadCountNull_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-1",
            "unread_count": null,
            "cursor": \(validCursorJsonString)
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
            "room_id": "cool-room-1",
            "unread_count": "not an int",
            "cursor": \(validCursorJsonString)
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"unread_count\"",
                                          "Expected to decode UInt64 but found a string/data instead."])
    }
    
    func test_init_cursorMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-1",
            "unread_count": 7,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"cursor\""])
    }
    
    func test_init_cursorNull_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-1",
            "unread_count": 7,
            "cursor": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"cursor\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_cursorInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-1",
            "unread_count": 7,
            "cursor": "not a cursor"
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.ReadState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"cursor\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
}
