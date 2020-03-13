import TestUtilities
import XCTest
@testable import PusherChatkit

class WireEventInitialStateDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.InitialState(from: jsonData.jsonDecoder())) { event in
            // Loosely verify all the child entities (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(event.currentUser.identifier, "alice")
            XCTAssertEqual(event.rooms.count, 1)
            XCTAssertEqual(event.readStates.count, 1)
            XCTAssertEqual(event.memberships.count, 2)
        }
    }
    
    func test_init_currentUserMissing_throws() {
        
        let jsonData = """
        {
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"current_user\""])
    }
    
    func test_init_currentUserNull_throws() {
        
        let jsonData = """
        {
            "current_user": null,
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"current_user\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_currentUserInvalidType_throws() {
        
        let jsonData = """
        {
            "current_user": "not a user",
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"current_user\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_currentUserInvalidFormat_throws() {
        
        // Note the `current_user` is missing its mandatory `id`
        let jsonData = """
        {
            "current_user": {
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_roomsMissing_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"rooms\""])
    }
    
    func test_init_roomsNull_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": null,
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"rooms\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_roomsInvalidType_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": "not an array",
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"rooms\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
    func test_init_roomInvalidFormat_throws() {
        
        // Note the first `room` is missing its mandatory `id`
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_membershipsMissing_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"memberships\""])
    }
    
    func test_init_membershipsNull_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": null,
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"memberships\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_membershipsInvalidType_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": "not an array",
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"memberships\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
    func test_init_membershipsInvalidFormat_throws() {
        
        // Note the first `memberships` is missing its mandatory `room_id`
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
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
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_readStatesMissing_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"read_states\""])
    }
    
    func test_init_readStatesNull_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"read_states\"",
                                          "Cannot get unkeyed decoding container -- found null value instead."])
    }
    
    func test_init_readStatesInvalidType_throws() {
        
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": "not an array",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"read_states\"",
                                          "Expected to decode Array<Any> but found a string/data instead."])
    }
    
    func test_init_readStatesInvalidFormat_throws() {
        
        // Note the first `readState` is missing its mandatory `room_id`
        let jsonData = """
        {
            "current_user": {
                "id": "alice",
                "name": "Alice A",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [
                {
                    "id": "ac43dfef",
                    "name": "Chatkit chat",
                    "private": false,
                    "created_at": "2017-03-23T11:36:42Z",
                    "updated_at": "2017-07-28T22:19:32Z",
                },
            ],
            "memberships": [
                {
                    "room_id": "ac43dfef",
                    "user_ids": ["alice", "carol"],
                },
                {
                    "room_id": "538a8fc",
                    "user_ids": ["bob", "carol"],
                },
            ],
            "read_states": [
                {
                    "unread_count": 7,
                    "cursor": {
                        "room_id": "ac43dfef",
                        "user_id": "alice",
                        "cursor_type": 0,
                        "position": 123654,
                        "updated_at": "2017-04-13T14:10:04Z"
                    }
                },
            ],
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.InitialState(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
}
