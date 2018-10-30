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

    init(
        onUserStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onUserStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onPresenceChanged: @escaping (PCPresenceStateChange, PCUser) -> Void = { _, _ in },
        onUserJoinedRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onUserLeftRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        onAddedToRoom: @escaping (PCRoom) -> Void = { _ in },
        onRemovedFromRoom: @escaping (PCRoom) -> Void = { _ in },
        onRoomDeleted: @escaping (PCRoom) -> Void = { _ in }
    ) {
        handleUserStartedTyping = onUserStartedTyping
        handleUserStoppedTyping = onUserStoppedTyping
        handlePresenceChanged = onPresenceChanged
        handleUserJoinedRoom = onUserJoinedRoom
        handleUserLeftRoom = onUserLeftRoom
        handleAddedToRoom = onAddedToRoom
        handleRemovedFromRoom = onRemovedFromRoom
        handleRoomDeleted = onRoomDeleted
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
}

class TestingRoomDelegate: NSObject, PCRoomDelegate {
    let handleNewCursor: (PCCursor) -> Void
    let handleUserStartedTyping: (PCUser) -> Void
    let handleUserStoppedTyping: (PCUser) -> Void
    let handlePresenceChanged: (PCPresenceStateChange, PCUser) -> Void
    let handleUserJoined: (PCUser) -> Void
    let handleUserLeft: (PCUser) -> Void
    let handleNewMessage: (PCMessage) -> Void

    init(
        onNewCursor: @escaping (PCCursor) -> Void = { _ in },
        onUserStartedTyping: @escaping (PCUser) -> Void = { _ in },
        onUserStoppedTyping: @escaping (PCUser) -> Void = { _ in },
        onPresenceChanged: @escaping (PCPresenceStateChange, PCUser) -> Void = { _, _ in },
        onUserJoined: @escaping (PCUser) -> Void = { _ in },
        onUserLeft: @escaping (PCUser) -> Void = { _ in },
        onMessage: @escaping (PCMessage) -> Void = { _ in }
    ) {
        handleNewCursor = onNewCursor
        handleUserStartedTyping = onUserStartedTyping
        handleUserStoppedTyping = onUserStoppedTyping
        handlePresenceChanged = onPresenceChanged
        handleUserJoined = onUserJoined
        handleUserLeft = onUserLeft
        handleNewMessage = onMessage
    }

    func onNewCursor(_ cursor: PCCursor) -> Void {
        handleNewCursor(cursor)
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
}
