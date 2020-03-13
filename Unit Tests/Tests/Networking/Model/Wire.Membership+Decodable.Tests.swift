import TestUtilities
import XCTest
@testable import PusherChatkit

class WireMembershipDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_ids": ["alice", "carol"],
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Membership(from: jsonData.jsonDecoder())) { membership in
            XCTAssertEqual(membership.roomIdentifier, "ac43dfef")
            XCTAssertEqual(membership.userIdentifiers, ["alice", "carol"])
        }
    }
    
    func test_init_userIdentifierDuplicates_entityFullyPopulatedWithDedupedUserIdentifiers() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_ids": ["alice", "carol", "alice"],
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Membership(from: jsonData.jsonDecoder())) { membership in
            XCTAssertEqual(membership.roomIdentifier, "ac43dfef")
            XCTAssertEqual(membership.userIdentifiers, ["alice", "carol"])
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "user_ids": ["alice", "carol"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "user_ids": ["alice", "carol"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "user_ids": ["alice", "carol"],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifiersMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_ids\""])
    }
    
    func test_init_userIdentifiersNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_ids": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_ids\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_userIdentifiersInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_ids": "not an array",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Membership(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_ids\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
}
