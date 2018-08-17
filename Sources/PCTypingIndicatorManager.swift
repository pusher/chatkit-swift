import Foundation
import PusherPlatform

let TYPING_INDICATOR_TTL = 1.5
let TYPING_INDICATOR_LEEWAY = 0.5

struct UserRoomPair: Hashable {
    let roomID: Int
    let userID: String
}

final class PCTypingIndicatorManager {
    var lastSentRequests = [Int: Date]()
    var timers = [UserRoomPair: Timer]()

    let instance: Instance

    init(instance: Instance) {
        self.instance = instance
    }

    func sendThrottledRequest(
        roomID: Int,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        let now = Date()
        let interval = TYPING_INDICATOR_TTL - TYPING_INDICATOR_LEEWAY

        if let seen = lastSentRequests[roomID], now.timeIntervalSince(seen) < interval {
            completionHandler(nil)
            return
        }

        lastSentRequests[roomID] = now

        instance.requestWithRetry(
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
        startHook: ((PCRoom, PCUser) -> Void)?,
        stopHook: ((PCRoom, PCUser) -> Void)?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                print("self is nil when setting read cursor timer")
                return
            }

            if let timer = strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)] {
                timer.invalidate()
                strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)] = nil
            } else {
                startHook?(room, user)
            }

            strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)] = Timer.scheduledTimer(
                withTimeInterval: TYPING_INDICATOR_TTL,
                repeats: false
            ) { _ in
                stopHook?(room, user)
                strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)]?.invalidate()
                strongSelf.timers[UserRoomPair(roomID: room.id, userID: user.id)] = nil
            }
        }
    }
}
