import XCTest
@testable import PusherChatkit

public class StubJoinedRoomsProviderDelegate: JoinedRoomsProviderDelegate {
    
    public typealias DidJoinRoom = (Room) -> Void
    public typealias DidUpdateRoom = (_ room: Room, _ previousValue: Room) -> Void
    public typealias DidLeaveRoom = (Room) -> Void
    
    private let onDidJoinRoom: DidJoinRoom?
    private let onDidUpdateRoom: DidUpdateRoom?
    private let onDidLeaveRoom: DidLeaveRoom?
    private let file: StaticString
    private let line: UInt
    
    public init(onDidJoinRoom: DidJoinRoom? = nil,
         onDidUpdateRoom: DidUpdateRoom? = nil,
         onDidLeaveRoom: DidLeaveRoom? = nil,
         file: StaticString = #file, line: UInt = #line) {
        self.onDidJoinRoom = onDidJoinRoom
        self.onDidUpdateRoom = onDidUpdateRoom
        self.onDidLeaveRoom = onDidLeaveRoom
        self.file = file
        self.line = line
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room) {
        guard let onDidJoinRoom = onDidJoinRoom else {
            XCTFail("No `onDidJoinRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidJoinRoom(room)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room) {
        guard let onDidUpdateRoom = onDidUpdateRoom else {
            XCTFail("No `onDidUpdateRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidUpdateRoom(room, previousValue)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room) {
        guard let onDidLeaveRoom = onDidLeaveRoom else {
            XCTFail("No `onDidLeaveRoom` defined in \(String(describing: self))", file: file, line: line)
            return
        }
        onDidLeaveRoom(room)
    }
    
}
