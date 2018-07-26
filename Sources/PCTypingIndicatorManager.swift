import Foundation
import PusherPlatform

// TODO are there already a load of constants defined somewhere?
let TYPING_INDICATOR_TTL = 1.5
let TYPING_INDICATOR_LEEWAY = 0.5

struct UserRoomPair: Hashable {
    let roomId: Int
    let userId: String
}

final class PCTypingIndicatorManager {
    var lastSentRequests = [Int: Date]()
    var timers = [UserRoomPair: Timer]()

    let instance: Instance

    init(
        instance: Instance
    ) {
        self.instance = instance
    }

    func sendThrottledRequest(
        roomId: Int,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        let now = Date()

        let interval = TYPING_INDICATOR_TTL - TYPING_INDICATOR_LEEWAY

        if let seen = lastSentRequests[roomId], now.timeIntervalSince(seen) < interval {
            completionHandler(nil)
            return
        }

        lastSentRequests[roomId] = now

        instance.requestWithRetry(
            using: PPRequestOptions(
                method: HTTPMethod.POST.rawValue,
                path: "/rooms/\(roomId)/typing_indicators"
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
        // TODO make access to timers thread safe

        if let timer = timers[UserRoomPair(roomId: room.id, userId: user.id)] {
            timer.invalidate()
            timers[UserRoomPair(roomId: room.id, userId: user.id)] = nil
        } else {
            globalStartHook?(room, user)
            roomStartHook?(user)
        }

        timers[UserRoomPair(roomId: room.id, userId: user.id)] = Timer.scheduledTimer(
            withTimeInterval: TYPING_INDICATOR_TTL,
            repeats: false
        ) { _ in
            globalStopHook?(room, user)
            roomStopHook?(user)
            self.timers[UserRoomPair(roomId: room.id, userId: user.id)] = nil
        }
    }
}
