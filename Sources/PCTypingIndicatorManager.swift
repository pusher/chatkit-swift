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
    var timers = [UserRoomPair: PPRepeater]()
    let instance: Instance

    init(
        instance: Instance
    ) {
        self.instance = instance
    }

    deinit {
        // TODO: Is this required?
        self.timers = [:]
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
            timers[UserRoomPair(roomId: room.id, userId: user.id)] = nil
        } else {
            globalStartHook?(room, user)
            roomStartHook?(user)
        }

        timers[UserRoomPair(roomId: room.id, userId: user.id)] = PPRepeater.once(
            after: .seconds(TYPING_INDICATOR_TTL)
        ) { [weak self] _ in
            guard let strongSelf = self else {
                print("self is nil when about to call signal typing has stopped")
                return
            }

            globalStopHook?(room, user)
            roomStopHook?(user)
            strongSelf.timers[UserRoomPair(roomId: room.id, userId: user.id)] = nil
        }
    }
}
