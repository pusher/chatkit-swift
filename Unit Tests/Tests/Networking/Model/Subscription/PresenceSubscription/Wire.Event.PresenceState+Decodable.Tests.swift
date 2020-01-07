import XCTest
@testable import PusherChatkit

class WireEventPresenceStateDecodableTests: XCTestCase {
    
    func test_init_online_noProblem() {
        
        let jsonData = """
        {
            "state": "online",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.PresenceState(from: jsonData.jsonDecoder())) { presenceState in
            XCTAssertEqual(presenceState, .online)
        }
    }
    
    func test_init_offline_noProblem() {
        
        let jsonData = """
        {
            "state": "offline",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.PresenceState(from: jsonData.jsonDecoder())) { presenceState in
            XCTAssertEqual(presenceState, .offline)
        }
    }
    
    func test_init_stateMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.PresenceState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"state\""])
    }
    
    func test_init_stateNull_throws() {
        
        let jsonData = """
        {
            "state": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.PresenceState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"state\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_stateInvalidType_throws() {
        
        let jsonData = """
        {
            "state": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.PresenceState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"state\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_stateNotSupported_throws() {
        
        let jsonData = """
        {
            "state": "not a supported presenceState value",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.PresenceState(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"state\"",
                                          "Cannot initialize PresenceState from invalid string value"])
    }
    
}
