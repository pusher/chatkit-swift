import XCTest
import PusherPlatform
@testable import PusherChatkit

func testUser(userId: String) -> ChatManager {
    return ChatManager(
        instanceLocator: testInstanceLocator,
        tokenProvider: PCTokenProvider(url: testInstanceTokenProviderURL),
        userId: userId,
        logger: TestLogger()
    )
}

class CursorTests: XCTestCase {
    var aliceManager: ChatManager?
    var bobManager: ChatManager?
    var room: PCRoom?
    
    // Currently these tests only pass if the users "alice" and "bob" already exist.
    override func setUp() {
        let ex = expectation(description: "Room is created")
        if aliceManager == nil {
            aliceManager = testUser(userId: "alice")
        }
        if bobManager == nil {
            aliceManager = testUser(userId: "bob")
        }
        if room == nil {
            aliceManager?.connect(delegate: TestingChatManagerDelegate()) { alice, error in
                XCTAssertNil(error)
                
                alice?.createRoom(name: "Alice's room") { r, error in
                    XCTAssertNil(error)
                    
                    self.room = r
                    
                    ex.fulfill()
                }
            }
        } else {
            ex.fulfill()
        }
        super.setUp()
        waitForExpectations(timeout: 5)
    }
    
    func testOwnReadCursorUndefinedIfNotSet() {
        let ex = expectation(description: "Get empty cursor after connection")
        
        aliceManager?.connect(delegate: TestingChatManagerDelegate()) { alice, error in
            XCTAssertNil(error)
            XCTAssertNotNil(alice)
            
            let cursor = try! alice!.readCursor(roomId: self.room!.id)
            
            XCTAssertNil(cursor)
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testSomethingElse() {
        print("TESTING SOMETHING ELSE!")
    }
}
