import Foundation
import PusherChatkit

class TestingChatManagerDelegate: PCChatManagerDelegate {
    let handleUserStartedTyping: (PCRoom, PCUser) -> Void
    let handleUserStoppedTyping: (PCRoom, PCUser) -> Void
    let handleUserPresenceChanged: (PCPresenceState, PCPresenceState, PCUser) -> Void
    let handleUserJoinedRoom: (PCRoom, PCUser) -> Void
    let handleUserLeftRoom: (PCRoom, PCUser) -> Void
    let handleAddedToRoom: (PCRoom) -> Void
    let handleRemovedFromRoom: (PCRoom) -> Void
    let handleRoomDeleted: (PCRoom) -> Void

    init(
        userStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userPresenceChanged: @escaping (PCPresenceState, PCPresenceState, PCUser) -> Void = { _, _, _ in },
        userJoinedRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userLeftRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        addedToRoom: @escaping (PCRoom) -> Void = { _ in },
        removedFromRoom: @escaping (PCRoom) -> Void = { _ in },
        roomDeleted: @escaping (PCRoom) -> Void = { _ in }
    ) {
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserPresenceChanged = userPresenceChanged
        handleUserJoinedRoom = userJoinedRoom
        handleUserLeftRoom = userLeftRoom
        handleAddedToRoom = addedToRoom
        handleRemovedFromRoom = removedFromRoom
        handleRoomDeleted = roomDeleted
    }

    func userStartedTyping(room: PCRoom, user: PCUser) -> Void {
        handleUserStartedTyping(room, user)
    }

    func userStoppedTyping(room: PCRoom, user: PCUser) -> Void {
        handleUserStoppedTyping(room, user)
    }

    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {
        handleUserPresenceChanged(previous, current, user)
    }

    func userJoinedRoom(room: PCRoom, user: PCUser) {
        handleUserJoinedRoom(room, user)
    }

    func userLeftRoom(room: PCRoom, user: PCUser) {
        handleUserLeftRoom(room, user)
    }

    func addedToRoom(room: PCRoom) {
        handleAddedToRoom(room)
    }

    func removedFromRoom(room: PCRoom) {
        handleRemovedFromRoom(room)
    }

    func roomDeleted(room: PCRoom) {
        handleRoomDeleted(room)
    }
}

class TestingRoomDelegate: NSObject, PCRoomDelegate {
    let handleNewCursor: (PCCursor) -> Void
    let handleUserStartedTyping: (PCUser) -> Void
    let handleUserStoppedTyping: (PCUser) -> Void
    let handleUserPresenceChanged: (PCPresenceState, PCPresenceState, PCUser) -> Void
    let handleUserJoined: (PCUser) -> Void
    let handleUserLeft: (PCUser) -> Void
    let handleNewMessage: (PCMessage) -> Void

    init(
        newCursor: @escaping (PCCursor) -> Void = { _ in },
        userStartedTyping: @escaping (PCUser) -> Void = { _ in },
        userStoppedTyping: @escaping (PCUser) -> Void = { _ in },
        userPresenceChanged: @escaping (PCPresenceState, PCPresenceState, PCUser) -> Void = { _, _, _ in },
        userJoined: @escaping (PCUser) -> Void = { _ in },
        userLeft: @escaping (PCUser) -> Void = { _ in },
        newMessage: @escaping (PCMessage) -> Void = { _ in }
    ) {
        handleNewCursor = newCursor
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserPresenceChanged = userPresenceChanged
        handleUserJoined = userJoined
        handleUserLeft = userLeft
        handleNewMessage = newMessage
    }

    func newCursor(cursor: PCCursor) -> Void {
        handleNewCursor(cursor)
    }

    func userStartedTyping(user: PCUser) -> Void {
        handleUserStartedTyping(user)
    }

    func userStoppedTyping(user: PCUser) -> Void {
        handleUserStoppedTyping(user)
    }

    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {
        handleUserPresenceChanged(previous, current, user)
    }

    func userJoined(user: PCUser) {
        handleUserJoined(user)
    }

    func userLeft(user: PCUser) {
        handleUserLeft(user)
    }

    func newMessage(message: PCMessage) {
        handleNewMessage(message)
    }
}
