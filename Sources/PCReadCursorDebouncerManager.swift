import Foundation
import PusherPlatform

class PCReadCursorDebouncerManager {
    private var roomIDsToDebouncers: [String: PCReadCursorDebouncer] = [:]
    private weak var currentUser: PCCurrentUser?

    init(currentUser: PCCurrentUser) {
        self.currentUser = currentUser
    }

    func set(cursorPosition position: Int, inRoomID roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        if let debouncer = roomIDsToDebouncers[roomID] {
            debouncer.set(position: position, completionHandler: completionHandler)
        } else {
            let debouncer = PCReadCursorDebouncer(roomID: roomID, currentUser: currentUser)
            roomIDsToDebouncers[roomID] = debouncer
            debouncer.set(position: position, completionHandler: completionHandler)
        }
    }
}

class PCReadCursorDebouncer {
    private var roomID: String
    private weak var currentUser: PCCurrentUser?
    private var interval: TimeInterval
    private var timer: PPRepeater?

    private var sendReadCursorPayload: (position: Int, completionHandlers: [PCErrorCompletionHandler])? = nil

    init(
        roomID: String,
        currentUser: PCCurrentUser?,
        intervalMilliseconds: Int = PCDefaults.readCursorDebounceIntervalMilliseconds
    ) {
        self.roomID = roomID
        self.currentUser = currentUser
        self.interval = Double(intervalMilliseconds  / 1000)
    }

    deinit {
        self.timer = nil
    }

    func set(position: Int, completionHandler: @escaping PCErrorCompletionHandler) {
        if sendReadCursorPayload != nil {
            sendReadCursorPayload!.position = max(position, sendReadCursorPayload!.position)
            sendReadCursorPayload!.completionHandlers = sendReadCursorPayload!.completionHandlers + [completionHandler]
        } else {
            sendReadCursorPayload = (
                position: position,
                completionHandlers: [completionHandler]
            )
        }

        guard timer == nil else { return }

        self.timer = PPRepeater.once(
            after: .seconds(interval)
        ) { [weak self] _ in
            guard let strongSelf = self else {
                print("self is nil when setting read cursor timer")
                return
            }

            strongSelf.sendReadCursor()
        }
    }

    @objc func sendReadCursor() {
        guard let currentUser = self.currentUser else {
            print("currentUser is nil so can't set read cursor")
            return
        }

        guard let payload = self.sendReadCursorPayload else {
            currentUser.instance.logger.log(
                "sendReadCursorPayload is nil so can't set read cursor",
                logLevel: .debug
            )
            return
        }

        let completionHandlersToCall = payload.completionHandlers

        currentUser.sendReadCursor(
            position: payload.position,
            roomID: roomID,
            completionHandler: { error in
                completionHandlersToCall.forEach { $0(error) }
            }
        )

        sendReadCursorPayload = nil
        timer = nil
    }
}
