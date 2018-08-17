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
    let handleNewMessage: (PCMessage) -> Void
    let handleNewCursor: (PCCursor) -> Void

    init(
        userStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userPresenceChanged: @escaping (PCPresenceState, PCPresenceState, PCUser) -> Void = { _, _, _ in },
        userJoinedRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userLeftRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        addedToRoom: @escaping (PCRoom) -> Void = { _ in },
        removedFromRoom: @escaping (PCRoom) -> Void = { _ in },
        roomDeleted: @escaping (PCRoom) -> Void = { _ in },
        newMessage: @escaping (PCMessage) -> Void = { _ in },
        newCursor: @escaping (PCCursor) -> Void = { _ in }
    ) {
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserPresenceChanged = userPresenceChanged
        handleUserJoinedRoom = userJoinedRoom
        handleUserLeftRoom = userLeftRoom
        handleAddedToRoom = addedToRoom
        handleRemovedFromRoom = removedFromRoom
        handleRoomDeleted = roomDeleted
        handleNewMessage = newMessage
        handleNewCursor = newCursor
    }

    func userStartedTyping(inRoom room: PCRoom, user: PCUser) -> Void {
        handleUserStartedTyping(room, user)
    }

    func userStoppedTyping(inRoom room: PCRoom, user: PCUser) -> Void {
        handleUserStoppedTyping(room, user)
    }

    func userPresenceChanged(previous: PCPresenceState, current: PCPresenceState, user: PCUser) {
        handleUserPresenceChanged(previous, current, user)
    }

    func userJoinedRoom(_ room: PCRoom, user: PCUser) {
        handleUserJoinedRoom(room, user)
    }

    func userLeftRoom(_ room: PCRoom, user: PCUser) {
        handleUserLeftRoom(room, user)
    }

    func addedToRoom(_ room: PCRoom) {
        handleAddedToRoom(room)
    }

    func removedFromRoom(_ room: PCRoom) {
        handleRemovedFromRoom(room)
    }

    func roomDeleted(room: PCRoom) {
        handleRoomDeleted(room)
    }

    func newMessage(_ message: PCMessage) {
        handleNewMessage(message)
    }

    func newCursor(_ cursor: PCCursor) {
        handleNewCursor(cursor)
    }
}
