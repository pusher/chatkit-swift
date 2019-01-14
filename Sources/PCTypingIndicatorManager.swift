import Foundation
import PusherPlatform

let TYPING_INDICATOR_TTL = 1.5
let TYPING_INDICATOR_LEEWAY = 0.5

struct UserRoomPair: Hashable {
    let roomID: String
    let userID: String
}

final class PCTypingIndicatorManager {
    var lastSentRequests = [String: Date]()
    var timers = [UserRoomPair: PPRepeater]()
    weak var instance: Instance?

    init(instance: Instance) {
        self.instance = instance
    }

    deinit {
        // TODO: Is this required?
        self.timers = [:]
    }

    func sendThrottledRequest(
        roomID: String,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        let now = Date()
        let interval = TYPING_INDICATOR_TTL - TYPING_INDICATOR_LEEWAY

        if let seen = lastSentRequests[roomID], now.timeIntervalSince(seen) < interval {
            completionHandler(nil)
            return
        }

        lastSentRequests[roomID] = now

        instance?.requestWithRetry(
            using: PPRequestOptions(
                method: HTTPMethod.POST.rawValue,
                path: "/rooms/\(roomID)/typing_indicators"
            ),
            onSuccess: { _ in completionHandler(nil) },
            onError: completionHandler
        )
    }

    func onIsTyping(
        room: PCRoom,
        user: PCUser,
        globalStartHook: ((PCRoom, PCUser) -> Void)?,
        globalStopHook: ((PCRoom, PCUser) -> Void)?,
        roomStartHook: ((PCUser) -> Void)?,
        roomStopHook: ((PCUser) -> Void)?
    ) {
        // TODO: make access to timers thread safe
        if let _ = timers[UserRoomPair(roomID: room.id, userID: user.id)] {
            timers[UserRoomPair(roomID: room.id, userID: user.id)] = nil
        } else {
            globalStartHook?(room, user)
            roomStartHook?(user)
        }

        timers[UserRoomPair(roomID: room.id, userID: user.id)] = PPRepeater.once(
            after: .seconds(TYPING_INDICATOR_TTL)
        ) { [weak self] _ in
            guard let strongSelf = self else {
                print("self is nil when about to signal typing has stopped")
                return
            }

            globalStopHook?(room, user)
            roomStopHook?(user)
            strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)] = nil
        }
    }
}
