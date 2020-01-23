import XCTest
@testable import PusherChatkit


typealias Instance = PusherChatkit.Instance


extension Chatkit {

    // TODO these functions exists just to make things compile for now
    
    convenience init(instanceLocator: String, instance: Instance) throws {
        try self.init(instanceLocator: instanceLocator, tokenProvider: TestTokenProvider())
    }
    convenience init(instanceLocator: String, dependencies: Dependencies) throws {
        try self.init(instanceLocator: instanceLocator, tokenProvider: TestTokenProvider(), dependencies: dependencies)
    }
    
    func joinRoom(id roomIdentifier: String, _ handler: (Result<Void, Error>) -> Void) {
        
    }
}



extension XCTestCase {

    /*
     Functional Test "Contexts" Explained
     
        ChatKitInitialised
            `Chatkit` instance has been initialised,
            `Chatkit.subscribe()` HAS NOT been invoked

        ChakitSubscribed
            `Chatkit` instance has been initialised
            `chatkit.subscribe()` HAS been invoked and handler called with `success`
            (i.e. the user subscription IS active)
        
        ChatKitSubscribedAndInitalStateFired
     
        ChatkitSubscribeFailure
            `Chatkit` instance has been initialised
            `chatkit.subscribe()` HAS been invoked and handler called with `failure`
            (i.e. the user subscription is NOT active)

        JoinedRoomsProviderInitialised
            As "ChatkitSubscribedWithSuccess"
            `JoinedRoomsProvider` instance has been initialised (via `chatKit.makeJoinedRoomsProvider()`)
     
    */
    
    
    // TODO remove this method & returning of `dependencies` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_ChatKitInitialised_withDependencies(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, Dependencies)  {
        
        let stubNetworking = StubNetworking(file: file, line: line)
        let dependencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator, instanceFactory: stubNetworking)
        
        let chatkit = try Chatkit(instanceLocator: DummyInstanceLocator, dependencies: dependencies)
        
        return (stubNetworking, chatkit, dependencies)
    }
        
    func setUp_ChatKitInitialised(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit)  {
        
        let (stubNetworking, chatkit, _) = try setUp_ChatKitInitialised_withDependencies(file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
    func setUp_ChatKitSubscribed(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit)  {

        let (stubNetworking, chatkit, _) = try setUp_ChatKitSubscribed_withStoreBroadcaster(file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
    // TODO remove this method & returning of `storeBroadcaster` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_ChatKitSubscribed_withStoreBroadcaster(file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, StoreBroadcaster)  {

        let (stubNetworking, chatkit, dependencies) = try setUp_ChatKitInitialised_withDependencies(file: file, line: line)
        
        // Prepare for the client to register for a user subscription
        // Fire the "initial_state" User subscription event which will cause `Chatkit` to become successfully `connected`
        stubNetworking.stubSubscribe(.user, .success)
        
        let expectation = self.expectation(description: "`ChatKit.connect` completion handler should be invoked")
        chatkit.connect { _ in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)

        XCTAssertEqual(chatkit.connectionStatus, .connected, file: file, line: line)
        
        return (stubNetworking, chatkit, dependencies.storeBroadcaster)
    }
    
    func setUp_InitalStateFired(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit)  {
        let (stubNetworking, chatkit, _) = try setUp_InitalStateFired_withStoreBroadcaster(initialState: initialStateJsonData, file: file, line: line)
        return (stubNetworking, chatkit)
    }
    
    // TODO remove this method & returning of `storeBroadcaster` once we've properly implemented JoinedRoomProvider & Transformers
    func setUp_InitalStateFired_withStoreBroadcaster(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, StoreBroadcaster)  {

        let (stubNetworking, chatkit, storeBroadcaster) = try setUp_ChatKitSubscribed_withStoreBroadcaster(file: file, line: line)
        
        stubNetworking.fireSubscriptionEvent(.user, initialStateJsonData)
        
        return (stubNetworking, chatkit, storeBroadcaster)
    }
    
    func setUp_JoinedRoomsProviderInitialised(initialState initialStateJsonData: Data, file: StaticString = #file, line: UInt = #line) throws -> (StubNetworking, Chatkit, JoinedRoomsProvider) {
        
        let (stubNetworking, chatkit) = try setUp_InitalStateFired(initialState: initialStateJsonData, file: file, line: line)
        
        let expectation = self.expectation(description: "`ChatKit.createJoinedRoomsProvider` completion handler should be invoked")
        
        var joinedRoomsProviderOut: JoinedRoomsProvider!
        chatkit.createJoinedRoomsProvider { (joinedRoomsProvider, error) in
            joinedRoomsProviderOut = joinedRoomsProvider!
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        return (stubNetworking, chatkit, joinedRoomsProviderOut!)
    }
    
    
}

class Functional_ChatkitInitialised_Tests: XCTestCase {
    
    func test_chatkitConnect_userSubscriptionRegistrationSuccess_returnsSuccess() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (stubNetworking, chatkit) = try setUp_ChatKitInitialised()

            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            // Prepare user subscription to return success when the client attempts to register
            stubNetworking.stubSubscribe(.user, .success)
            
            let expectation = self.expectation(description: "`ChatKit.connect` completion handler should be invoked")
            var actualError: Error?
            chatkit.connect() { error in
                actualError = error
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            XCTAssertNil(actualError)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
        }())
    }
    
    func test_chatkitConnect_userSubscriptionRegistrationFailure_returnsSuccess() {
    
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (stubNetworking, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            // Prepare user subscription to return failure when the client attempts to register
            stubNetworking.stubSubscribe(.user, .failure("Failure"))
            
            let expectation = self.expectation(description: "`ChatKit.connect` completion handler should be invoked")
            var actualError: Error?
            chatkit.connect() { error in
                actualError = error
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            XCTAssertEqual(actualError as? String, "Failure")
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
        }())
    }
    
    func test_chatkitDisconnect_remainsDisconnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            chatkit.disconnect()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
        }())
    }
    
    func test_chatkitCreateJoinedRoomsProvider_returnsError() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitInitialised()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            var result: (joinedRoomsProvider: JoinedRoomsProvider?, error: Error?)!
            chatkit.createJoinedRoomsProvider { (joinedRoomsProvider, error) in
                result = (joinedRoomsProvider, error)
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertNil(result.joinedRoomsProvider)
            // TODO improved assertion to better check content of error
            XCTAssertNotNil(result.error)
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
        }())
    }

}

class Functional_ChatkitSubscribed_Tests: XCTestCase {
    
    func test_chatkitConnect_returnsSuccessDoesNotAttemptReconnectionAndRemainsConnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitSubscribed()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = self.expectation(description: "`ChatKit.connect` completion handler should be invoked")
            var actualError: Error?
            chatkit.connect() { error in
                actualError = error
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            // `connect` is idempotent - chatkit remains connected, no reconnection is attempted and no error is returned,
            XCTAssertNil(actualError)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
        }())
    }
    
    func test_chatkitDisconnect_chatkitBecomesDisconnected() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitSubscribed()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            chatkit.disconnect()
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            XCTAssertEqual(chatkit.connectionStatus, .disconnected)
        }())
    }
    
    func test_chatkitCreateJoinedRoomsProvider_returnsJoinedRoomsProvider() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (_, chatkit) = try setUp_ChatKitSubscribed()
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = self.expectation(description: "`ChatKit.createJoinedRoomsProvider` completion handler should be invoked")
            var result: (joinedRoomsProvider: JoinedRoomsProvider?, error: Error?)!
            chatkit.createJoinedRoomsProvider { (joinedRoomsProvider, error) in
                result = (joinedRoomsProvider, error)
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            XCTAssertNotNil(result.joinedRoomsProvider)
            XCTAssertNil(result.error)
            XCTAssertEqual(chatkit.connectionStatus, .connected)
        }())
    }
    
    func test_storeBroadcasterRegister_listenerReceivesStateOnSubscriptionEvents() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let (stubNetworking, _, storeBroadcaster) = try setUp_ChatKitSubscribed_withStoreBroadcaster()
            
            let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 2)
            
            XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
            
            var latestState: State?
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            latestState = storeBroadcaster.register(stubStoreListener)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            XCTAssertEqual(latestState, State.emptyState)
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [
                        {
                            "id": "ac43dfef",
                            "name": "Chatkit chat",
                            "created_by_id": "alice",
                            "private": false,
                            "created_at": "2017-03-23T11:36:42Z",
                            "updated_at": "2017-07-28T22:19:32Z",
                        }
                    ],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            stubNetworking.fireSubscriptionEvent(.user, initialStateJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            latestState = stubStoreListener.didUpdateState_stateLastReceived
            XCTAssertEqual(latestState?.joinedRooms.count, 1)
            XCTAssertEqual(latestState?.joinedRooms[0].identifier, "ac43dfef")
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
            
            /******************/
            /*----- WHEN -----*/
            /******************/

            let removedFromRoomEventJsonData = """
            {
                "event_name": "removed_from_room",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "room_id": "ac43dfef",
                },
            }
            """.toJsonData()
            
            stubNetworking.fireSubscriptionEvent(.user, removedFromRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            latestState = stubStoreListener.didUpdateState_stateLastReceived
            XCTAssertEqual(latestState?.joinedRooms.count, 0)
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 2)

        }())
        
    }

}

class Functional_InitialStateFired_Tests: XCTestCase {
    
    func test_storeBroadcasterRegister_listenerReceivesStateOnSubscriptionEvents() {

        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z"
                    },
                    "rooms": [
                        {
                            "id": "ac43dfef",
                            "name": "Chatkit chat",
                            "created_by_id": "alice",
                            "private": false,
                            "created_at": "2017-03-23T11:36:42Z",
                            "updated_at": "2017-07-28T22:19:32Z",
                        }
                    ],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, _, storeBroadcaster) = try setUp_InitalStateFired_withStoreBroadcaster(initialState: initialStateJsonData)
            
            let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
            
            XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
            
            var latestState: State?
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            latestState = storeBroadcaster.register(stubStoreListener)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            XCTAssertEqual(latestState?.joinedRooms.count, 1)
            XCTAssertEqual(latestState?.joinedRooms[0].identifier, "ac43dfef")
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/

            let removedFromRoomEventJsonData = """
            {
                "event_name": "removed_from_room",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "room_id": "ac43dfef",
                },
            }
            """.toJsonData()
            
            stubNetworking.fireSubscriptionEvent(.user, removedFromRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            latestState = stubStoreListener.didUpdateState_stateLastReceived
            XCTAssertEqual(latestState?.joinedRooms.count, 0)
            XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)

        }())
    }
}
    

class Functional_JoinedRoomsProviderInitialised_Tests: XCTestCase {
        
    func test_removedFromRoomRemotely_success() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateEventJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-03-23T11:36:42Z",
                "data": {
                    "current_user": {
                        "id": "alice",
                        "name": "Alice A",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z",
                    },
                    "rooms": [
                        {
                            "id": "ac43dfef",
                            "name": "Chatkit chat",
                            "created_by_id": "alice",
                            "private": false,
                            "created_at": "2017-03-23T11:36:42Z",
                            "updated_at": "2017-07-28T22:19:32Z",
                        }
                    ],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, _, joinedRoomsProvider) = try setUp_JoinedRoomsProviderInitialised(initialState: initialStateEventJsonData)
            
            let expectation = self.expectation(description: "`JoinedRoomsProviderDelegate` `didLeaveRoom` should be invoked")
            let stubJoinedRoomsProviderDelegate = StubJoinedRoomsProviderDelegate(onDidLeaveRoom: { room in
                expectation.fulfill()
            })
            joinedRoomsProvider.delegate = stubJoinedRoomsProviderDelegate
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 1)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let removedFromRoomEventJsonData = """
            {
                "event_name": "removed_from_room",
                "timestamp": "2017-04-14T14:00:42Z",
                "data": {
                    "room_id": "ac43dfef",
                },
            }
            """.toJsonData()
            stubNetworking.fireSubscriptionEvent(.user, removedFromRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            // Wait for the delegate's `didLeaveRoom` func to fire (to allow time for the joined room to propagate through the state machine)
            waitForExpectations(timeout: 1)
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 0)
            
        }())
    }
    
    func test_addedToRoomLocally_success() {
        
        XCTAssertNoThrow(try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateEventJsonData = """
            {
                "event_name": "initial_state",
                "timestamp": "2017-03-23T11:36:42Z",
                "data": {
                    "current_user": {
                        "id": "viv",
                        "name": "Vivan",
                        "created_at": "2017-04-13T14:10:04Z",
                        "updated_at": "2017-04-13T14:10:04Z",
                    },
                    "rooms": [],
                    "read_states": [],
                    "memberships": [],
                },
            }
            """.toJsonData()
            
            let (stubNetworking, chatkit, joinedRoomsProvider) = try self.setUp_JoinedRoomsProviderInitialised(initialState: initialStateEventJsonData)
            
            let expectationA = self.expectation(description: "JoinedRoomsProviderDelegate.didJoinRoom will be invoked")
            let stubJoinedRoomsProviderDelegate = StubJoinedRoomsProviderDelegate(onDidJoinRoom: { room in
                expectationA.fulfill()
            })
            joinedRoomsProvider.delegate = stubJoinedRoomsProviderDelegate
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let joinRoomJsonData = """
            {
                "id": "cool-room-1",
                "created_by_id": "jean",
                "name": "mycoolroom",
                "private": false,
                "last_message_at": "2017-04-23T11:36:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "member_user_ids": ["ham"]
            }
            """.toJsonData()
            
            stubNetworking.stub("/users/test-user/rooms/test-room/join", joinRoomJsonData)
            
            let expectationB = self.expectation(description: "")
            chatkit.joinRoom(id: "test-room") { result in
                expectationB.fulfill()
            }
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            // Wait for two things:
            //  a) The call to `chatkit.joinRoom` to return
            //  b) The delegate's `didJoinRoom` func to fire (to allow time for the joined room to propagate through the state machine)
            self.waitForExpectations(timeout: 1)
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 1)
            
        }())
        
    }

}


