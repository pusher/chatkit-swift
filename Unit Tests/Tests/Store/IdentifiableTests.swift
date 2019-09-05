import XCTest
@testable import PusherChatkit

class IdentifiableTests: XCTestCase {
    
    // MARK: - Tests
    
    func testMessageShouldImplementIdentifiableProtocol() {
        let type: Any = Message.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
    func testRoomShouldImplementIdentifiableProtocol() {
        let type: Any = Room.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
    func testUserShouldImplementIdentifiableProtocol() {
        let type: Any = User.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
    func testMessageEntityShouldImplementIdentifiableProtocol() {
        let type: Any = MessageEntity.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
    func testRoomEntityShouldImplementIdentifiableProtocol() {
        let type: Any = RoomEntity.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
    func testUserEntityShouldImplementIdentifiableProtocol() {
        let type: Any = UserEntity.self
        
        XCTAssertTrue(type is Identifiable.Type)
    }
    
}
