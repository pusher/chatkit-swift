import Foundation

public final class PCTypingIndicatorManager {
    private var queue = DispatchQueue(label: "com.pusher.chatkit.typing-indicator-manager")
    public var typingTimeoutTimer: Timer?
    public var typingTimeoutInterval: TimeInterval
    public let roomId: Int
    public internal(set) var isTyping: Bool = false
    var currentUser: PCCurrentUser

    public init(
        typingTimeoutInterval: TimeInterval = 3,
        roomId: Int,
        currentUser: PCCurrentUser
    ) {
        self.typingTimeoutInterval = typingTimeoutInterval
        self.roomId = roomId
        self.currentUser = currentUser
    }

    deinit {
        self.typingTimeoutTimer?.invalidate()
    }

    public func typing() {
        self.queue.sync {
            if !self.isTyping {
                self.isTyping = true
                self.signalTypingStarted()
            }

            self.typingTimeoutTimer?.invalidate()

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    print("self is nil when about to call stopTyping function")
                    return
                }

                strongSelf.typingTimeoutTimer = Timer.scheduledTimer(
                    timeInterval: strongSelf.typingTimeoutInterval,
                    target: strongSelf,
                    selector: #selector(strongSelf.stopTyping),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }

    @objc public func stopTyping() {
        self.queue.sync {
            self.isTyping = false
            self.typingTimeoutTimer?.invalidate()
            self.signalTypingStopped()
        }
    }

    public func signalTypingStarted() {
        self.currentUser.startedTypingIn(roomId: self.roomId) { err in
            if let error = err {
                self.currentUser.instance.logger.log("Error sending typing_start event: \(error.localizedDescription)", logLevel: .debug)
            }
        }
    }

    public func signalTypingStopped() {
        self.currentUser.stoppedTypingIn(roomId: self.roomId) { err in
            if let error = err {
                self.currentUser.instance.logger.log("Error sending typing_stop event: \(error.localizedDescription)", logLevel: .debug)
            }
        }
    }
}
