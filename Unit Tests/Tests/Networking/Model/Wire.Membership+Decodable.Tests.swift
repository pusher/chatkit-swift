import XCTest
@testable import PusherChatkit

class WireMemebershipDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_ids": ["viv", "flo"],
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Membership(from: jsonData.jsonDecoder())) { membership in
            XCTAssertEqual(membership.roomIdentifier, "cool-room-2")
            XCTAssertEqual(membership.userIdentifiers, ["viv", "flo"])
        }
    }
    
    func test_init_roomIdentiferMissing_throws() {
        
        let jsonData = """
        {
            "user_ids": ["viv", "flo"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentiferNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "user_ids": ["viv", "flo"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentiferInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "user_ids": ["viv", "flo"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifersMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_ids\""])
    }
    
    func test_init_userIdentifersNull_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_ids": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_ids\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_userIdentifersInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_ids": "not an array",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_ids\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
}
