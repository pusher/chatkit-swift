import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class WireEventNewMessageDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.NewMessage(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.message.identifier, 2)
            XCTAssertEqual(event.message.roomIdentifier, "ac43dfef")
            XCTAssertEqual(event.message.userIdentifier, "alice")
            XCTAssertEqual(event.message.parts.count, 1)
            XCTAssertEqual(event.message.createdAt, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            XCTAssertEqual(event.message.updatedAt, Date(fromISO8601String: "2017-04-23T11:36:42Z"))
        }
    }
    
    func test_init_identifierMissing_throws() {
        
        let jsonData = """
        {
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_identifierNull_throws() {
        
        let jsonData = """
        {
            "id": null,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"id\"",
                                          "Expected Int64 value but found null instead."])
    }
    
    func test_init_identifierInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "not an int",
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"id\"",
                                          "Expected to decode Int64 but found a string/data instead."])
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": null,
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": 123,
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_id\""])
    }
    
    func test_init_userIdentifierNull_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": null,
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_userIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": 123,
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_partsMissing_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Message(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"parts\""])
    }
    
    func test_init_partsNull_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": null,
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"parts\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_partsInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": "not an array",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"parts\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
    func test_init_partsInvalidFormat_throws() {
        
        // Note the first `part` is missing its mandatory `type`
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"type\""])
    }
    
    func test_init_createdAtMissing_throws() {
          
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"created_at\""])
      }
      
      func test_init_createdAtNull_throws() {
          
          let jsonData = """
          {
              "id": 2,
              "user_id": "alice",
              "room_id": "ac43dfef",
              "parts": [
                  {
                      "type": "text/plain",
                      "content": "Hola!"
                  }
              ],
              "created_at": null,
              "updated_at": "2017-04-23T11:36:42Z"
          }
          """.toJsonData()
          
          XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                               containing: ["valueNotFound",
                                            "\"created_at\"",
                                            "Expected Date value but found null instead."])
      }
      
      func test_init_createdAtInvalidType_throws() {
          
          let jsonData = """
          {
              "id": 2,
              "user_id": "alice",
              "room_id": "ac43dfef",
              "parts": [
                  {
                      "type": "text/plain",
                      "content": "Hola!"
                  }
              ],
              "created_at": 123,
              "updated_at": "2017-04-23T11:36:42Z"
          }
          """.toJsonData()
          
          XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                               containing: ["typeMismatch",
                                            "\"created_at\"",
                                            "Expected to decode String but found a number instead."])
      }
      
      func test_init_createdAtInvalidFormat_throws() {
          
          let jsonData = """
          {
              "id": 2,
              "user_id": "alice",
              "room_id": "ac43dfef",
              "parts": [
                  {
                      "type": "text/plain",
                      "content": "Hola!"
                  }
              ],
              "created_at": "not a date",
              "updated_at": "2017-04-23T11:36:42Z"
          }
          """.toJsonData()
          
          XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                               containing: ["dataCorrupted",
                                            "\"created_at\"",
                                            "Expected date string to be ISO8601-formatted."])
      }
      
    func test_init_updatedAtMissing_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"updated_at\""])
    }
    
    func test_init_updatedAtNull_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"updated_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_updatedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"updated_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_updatedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": 2,
            "user_id": "alice",
            "room_id": "ac43dfef",
            "parts": [
                {
                    "type": "text/plain",
                    "content": "Hola!"
                },
            ],
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "not a date",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.NewMessage(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"updated_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
}
