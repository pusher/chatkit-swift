import XCTest
@testable import PusherChatkit

class StubJoinedRoomsProviderDelegate: JoinedRoomsProviderDelegate {
    
    typealias DidJoinRoom = (Room) -> Void
    typealias DidUpdateRoom = (_ room: Room, _ previousValue: Room) -> Void
    typealias DidLeaveRoom = (Room) -> Void
    
    private let onDidJoinRoom: DidJoinRoom?
    private let onDidUpdateRoom: DidUpdateRoom?
    private let onDidLeaveRoom: DidLeaveRoom?
    private let file: StaticString
    private let line: UInt
    
    init(onDidJoinRoom: DidJoinRoom? = nil,
         onDidUpdateRoom: DidUpdateRoom? = nil,
         onDidLeaveRoom: DidLeaveRoom? = nil,
         file: StaticString = #file, line: UInt = #line) {
        self.onDidJoinRoom = onDidJoinRoom
        self.onDidUpdateRoom = onDidUpdateRoom
        self.onDidLeaveRoom = onDidLeaveRoom
        self.file = file
        self.line = line
    }
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room) {
        guard let onDidJoinRoom = onDidJoinRoom else {
            XCTFail("No `onDidJoinRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidJoinRoom(room)
    }
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room) {
        guard let onDidUpdateRoom = onDidUpdateRoom else {
            XCTFail("No `onDidUpdateRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidUpdateRoom(room, previousValue)
    }
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room) {
        guard let onDidLeaveRoom = onDidLeaveRoom else {
            XCTFail("No `onDidLeaveRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidLeaveRoom(room)
    }
    
}
