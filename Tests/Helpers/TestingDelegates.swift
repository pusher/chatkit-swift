import Foundation
import PusherChatkit

class TestingChatManagerDelegate: PCChatManagerDelegate {
    let handleUserStartedTyping: (PCRoom, PCUser) -> Void
    let handleUserStoppedTyping: (PCRoom, PCUser) -> Void
    let handlePresenceChanged: (PCPresenceStateChange, PCUser) -> Void
    let handleUserJoinedRoom: (PCRoom, PCUser) -> Void
    let handleUserLeftRoom: (PCRoom, PCUser) -> Void
    let handleAddedToRoom: (PCRoom) -> Void
    let handleRemovedFromRoom: (PCRoom) -> Void
    let handleRoomDeleted: (PCRoom) -> Void
    let handleRoomUpdated: (PCRoom) -> Void
    let handleNewReadCursor: (PCCursor) -> Void

    init(
        onUserStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onUserStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onPresenceChanged: @escaping (PCPresenceStateChange, PCUser) -> Void = { _, _ in },
        onUserJoinedRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onUserLeftRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onAddedToRoom: @escaping (PCRoom) -> Void = { _ in },
        onRemovedFromRoom: @escaping (PCRoom) -> Void = { _ in },
        onRoomDeleted: @escaping (PCRoom) -> Void = { _ in },
        onRoomUpdated: @escaping (PCRoom) -> Void = { _ in },
        onNewReadCursor: @escaping (PCCursor) -> Void = { _ in }
    ) {
        handleUserStartedTyping = onUserStartedTyping
        handleUserStoppedTyping = onUserStoppedTyping
        handlePresenceChanged = onPresenceChanged
        handleUserJoinedRoom = onUserJoinedRoom
        handleUserLeftRoom = onUserLeftRoom
        handleAddedToRoom = onAddedToRoom
        handleRemovedFromRoom = onRemovedFromRoom
        handleRoomDeleted = onRoomDeleted
        handleRoomUpdated = onRoomUpdated
        handleNewReadCursor = onNewReadCursor
    }

    func onUserStartedTyping(inRoom room: PCRoom, user: PCUser) -> Void {
        handleUserStartedTyping(room, user)
    }

    func onUserStoppedTyping(inRoom room: PCRoom, user: PCUser) -> Void {
        handleUserStoppedTyping(room, user)
    }

    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
        handlePresenceChanged(stateChange, user)
    }

    func onUserJoinedRoom(_ room: PCRoom, user: PCUser) {
        handleUserJoinedRoom(room, user)
    }

    func onUserLeftRoom(_ room: PCRoom, user: PCUser) {
        handleUserLeftRoom(room, user)
    }

    func onAddedToRoom(_ room: PCRoom) {
        handleAddedToRoom(room)
    }

    func onRemovedFromRoom(_ room: PCRoom) {
        handleRemovedFromRoom(room)
    }

    func onRoomDeleted(room: PCRoom) {
        handleRoomDeleted(room)
    }

    func onRoomUpdated(room: PCRoom) {
        handleRoomUpdated(room)
    }

    func onNewReadCursor(_ cursor: PCCursor) {
        handleNewReadCursor(cursor)
    }
}

class TestingRoomDelegate: NSObject, PCRoomDelegate {
    let handleNewReadCursor: (PCCursor) -> Void
    let handleUserStartedTyping: (PCUser) -> Void
    let handleUserStoppedTyping: (PCUser) -> Void
    let handlePresenceChanged: (PCPresenceStateChange, PCUser) -> Void
    let handleUserJoined: (PCUser) -> Void
    let handleUserLeft: (PCUser) -> Void
    let handleNewMessage: (PCMessage) -> Void
    let handleMultipartMessage: (PCMultipartMessage) -> Void
    let handleMessageDeleted: (Int) -> Void

    init(
        onNewReadCursor: @escaping (PCCursor) -> Void = { _ in },
        onUserStartedTyping: @escaping (PCUser) -> Void = { _ in },
        onUserStoppedTyping: @escaping (PCUser) -> Void = { _ in },
        onPresenceChanged: @escaping (PCPresenceStateChange, PCUser) -> Void = { _, _ in },
        onUserJoined: @escaping (PCUser) -> Void = { _ in },
        onUserLeft: @escaping (PCUser) -> Void = { _ in },
        onMessage: @escaping (PCMessage) -> Void = { _ in },
        onMultipartMessage: @escaping (PCMultipartMessage) -> Void = { _ in },
        onMessageDeleted: @escaping (Int) -> Void = { _ in }
    ) {
        handleNewReadCursor = onNewReadCursor
        handleUserStartedTyping = onUserStartedTyping
        handleUserStoppedTyping = onUserStoppedTyping
        handlePresenceChanged = onPresenceChanged
        handleUserJoined = onUserJoined
        handleUserLeft = onUserLeft
        handleNewMessage = onMessage
        handleMultipartMessage = onMultipartMessage
        handleMessageDeleted = onMessageDeleted
    }

    func onNewReadCursor(_ cursor: PCCursor) -> Void {
        handleNewReadCursor(cursor)
    }

    func onUserStartedTyping(user: PCUser) -> Void {
        handleUserStartedTyping(user)
    }

    func onUserStoppedTyping(user: PCUser) -> Void {
        handleUserStoppedTyping(user)
    }

    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
        handlePresenceChanged(stateChange, user)
    }

    func onUserJoined(user: PCUser) {
        handleUserJoined(user)
    }

    func onUserLeft(user: PCUser) {
        handleUserLeft(user)
    }

    func onMessage(_ message: PCMessage) {
        handleNewMessage(message)
    }
    
    func onMultipartMessage(_ message: PCMultipartMessage) {
        handleMultipartMessage(message)
    }

    func onMessageDeleted(_ messageID: Int) {
        handleMessageDeleted(messageID)
    }
}
