import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class WireEventRemovedFromRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.RemovedFromRoom(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.roomIdentifier, "ac43dfef")
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RemovedFromRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RemovedFromRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RemovedFromRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
}
