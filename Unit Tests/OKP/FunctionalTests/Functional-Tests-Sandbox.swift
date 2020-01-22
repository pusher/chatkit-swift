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
    
    func setUpChatKit(initialState initialStateJsonData: Data) throws -> (StubNetworking, Chatkit)  {

        let stubNetworking = StubNetworking()
        let depedencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator, instanceFactory: stubNetworking)
        
        let chatkit = try Chatkit(instanceLocator: DummyInstanceLocator, dependencies: depedencies)
        
        // Prepare for the client to register for a user subscription
        stubNetworking.stubSubscribe(.session, .success(()))
        
        let expectation = self.expectation(description: "Waiting for ChatKit to become connected")
        chatkit.connect { _ in
            expectation.fulfill()
        }
        
        // Fire the "initial_state" User subscription event which will cause `Chatkit` to become successfully `connected`
        stubNetworking.fireSubscriptionEvent(.session, initialStateJsonData)
        
        waitForExpectations(timeout: 1)
        
        return (stubNetworking, chatkit)
    }
    
    func setUpJoinedRoomsProvider(initialState initialStateJsonData: Data) throws -> (StubNetworking, Chatkit, JoinedRoomsProvider) {
        
        let (stubNetworking, chatkit) = try setUpChatKit(initialState: initialStateJsonData)
        
        let expectation = self.expectation(description: "Waiting for JoinedRoomsProvider to be instantiated")
        
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
    
    func test_chatkitConnect_userSubscribeSucceeds_success() {
    
        XCTAssertNoThrow( try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let stubNetworking = StubNetworking()
            let depedencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator, instanceFactory: stubNetworking)
            
            let chatkit = try Chatkit(instanceLocator: DummyInstanceLocator, dependencies: depedencies)

            // Prepare for the client to register for a user subscription
            stubNetworking.stubSubscribe(.session, .success(()))
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            let expectation = self.expectation(description: "Waiting for ChatKit to become connected")
            var result: Error?
            chatkit.connect() { error in
                result = error
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            XCTAssertNil(result)
        }())
    }
    
    func test_chatkitConnect_userSubscribeFails_success() {
    
        XCTAssertNoThrow( try {
        
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let stubNetworking = StubNetworking()
            let depedencies = ConcreteDependencies(instanceLocator: DummyInstanceLocator, instanceFactory: stubNetworking)
            
            let chatkit = try Chatkit(instanceLocator: DummyInstanceLocator, dependencies: depedencies)
            
            /*****************/
            /*---- WHEN -----*/
            /*****************/
            
            stubNetworking.stubSubscribe(.session, .failure("Failure"))
            
            let expectation = self.expectation(description: "Waiting for ChatKit to become connected")
            var result: Error?
            chatkit.connect() { error in
                result = error
                expectation.fulfill()
            }
            
            /*****************/
            /*---- THEN -----*/
            /*****************/
            
            waitForExpectations(timeout: 1)
            
            XCTAssertNotNil(result)
            XCTAssertEqual(result.debugDescription, "ChatKit could not connect, user unauthorized or something")
        }())
    }
    
    func test_chatkitDisconnect_success() {
        // Assume it should succeed (if its idempotent)
    }
    
    func test_createJoinedRoomsProvider_tbd() {
        // What happens if you try to create a Provider/ViewModel before calling `connect`?
    }
    
}
    

class JoinedRoomsProviderInitialisedFunctionalTests: XCTestCase {
        
    func test_removedFromRoomRemotely_success() {
        
        XCTAssertNoThrow(try {
            
            /******************/
            /*---- GIVEN -----*/
            /******************/
            
            let initialStateEventJsonData = """
            {
                "event_name": "initial_state",
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
                "timestamp": "2017-03-23T11:36:42Z"
            }
            """.toJsonData()
            
            let (stubNetworking, _, joinedRoomsProvider) = try setUpJoinedRoomsProvider(initialState: initialStateEventJsonData)
            
            let expectation = self.expectation(description: "JoinedRoomsProviderDelegate.didLeaveRoom will be invoked")
            let stubJoinedRoomsProviderDelegate = StubJoinedRoomsProviderDelegate(onDidLeaveRoom: { room in
                expectation.fulfill()
            })
            joinedRoomsProvider.delegate = stubJoinedRoomsProviderDelegate
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 0)
            
            /******************/
            /*----- WHEN -----*/
            /******************/
            
            let removedFromRoomEventJsonData = """
            {
                "data": {
                    "room_id": "cool-room-2",
                },
                "event_name": "removed_from_room",
                "timestamp": "2017-04-14T14:00:42Z",
            }
            """.toJsonData()
            stubNetworking.fireSubscriptionEvent(.session, removedFromRoomEventJsonData)
            
            /******************/
            /*----- THEN -----*/
            /******************/
            
            // Wait for the delegate's `didJoinRoom` func to fire (to allow time for the joined room to propagate through the state machine)
            waitForExpectations(timeout: 1)
            
            XCTAssertEqual(joinedRoomsProvider.rooms.count, 1)
            
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
                "timestamp": "2017-03-23T11:36:42Z"
            }
            """.toJsonData()
            
            let (stubNetworking, chatkit, joinedRoomsProvider) = try self.setUpJoinedRoomsProvider(initialState: initialStateEventJsonData)
            
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


