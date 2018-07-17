import Foundation
import PusherChatkit

class TestingChatManagerDelegate: PCChatManagerDelegate {
    let handleUserStartedTyping: (PCRoom, PCUser) -> Void
    let handleUserStoppedTyping: (PCRoom, PCUser) -> Void
    let handleUserCameOnline: (PCUser) -> Void
    let handleUserWentOffline: (PCUser) -> Void
    let handleUserJoinedRoom: (PCRoom, PCUser) -> Void
    let handleUserLeftRoom: (PCRoom, PCUser) -> Void
    let handleAddedToRoom: (PCRoom) -> Void
    let handleRemovedFromRoom: (PCRoom) -> Void
    let handleRoomDeleted: (PCRoom) -> Void

    init(
        userStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userCameOnline: @escaping (PCUser) -> Void = { _ in },
        userWentOffline: @escaping (PCUser) -> Void = { _ in },
        userJoinedRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userLeftRoom: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        addedToRoom: @escaping (PCRoom) -> Void = { _ in },
        removedFromRoom: @escaping (PCRoom) -> Void = { _ in },
        roomDeleted: @escaping (PCRoom) -> Void = { _ in }
    ) {
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserCameOnline = userCameOnline
        handleUserWentOffline = userWentOffline
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

    func userCameOnline(user: PCUser) -> Void {
        handleUserCameOnline(user)
    }

    func userWentOffline(user: PCUser) -> Void {
        handleUserWentOffline(user)
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
    let handleUserCameOnline: (PCUser) -> Void
    let handleUserWentOffline: (PCUser) -> Void
    let handleUserJoined: (PCUser) -> Void
    let handleUserLeft: (PCUser) -> Void

    init(
        newCursor: @escaping (PCCursor) -> Void = { _ in },
        userStartedTyping: @escaping (PCUser) -> Void = { _ in },
        userStoppedTyping: @escaping (PCUser) -> Void = { _ in },
        userCameOnline: @escaping (PCUser) -> Void = { _ in },
        userWentOffline: @escaping (PCUser) -> Void = { _ in },
        userJoined: @escaping (PCUser) -> Void = { _ in },
        userLeft: @escaping (PCUser) -> Void = { _ in }
    ) {
        handleNewCursor = newCursor
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserCameOnline = userCameOnline
        handleUserWentOffline = userWentOffline
        handleUserJoined = userJoined
        handleUserLeft = userLeft
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

    func userCameOnlineInRoom(user: PCUser) -> Void {
        handleUserCameOnline(user)
    }

    func userWentOfflineInRoom(user: PCUser) -> Void {
        handleUserWentOffline(user)
    }

    func userJoined(user: PCUser) {
        handleUserJoined(user)
    }

    func userLeft(user: PCUser) {
        handleUserLeft(user)
    }
}
