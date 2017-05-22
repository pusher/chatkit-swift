public class PCTypingIndicatorManager {
    private var queue = DispatchQueue(label: "com.pusher.chat-api.typing-indicator-manager")
    public var typingTimeoutTimer: Timer? = nil
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
        queue.sync {
            if !self.isTyping {
                self.isTyping = true
                self.signalTypingStarted()
            }

            self.typingTimeoutTimer?.invalidate()

            DispatchQueue.main.async {
                self.typingTimeoutTimer = Timer.scheduledTimer(
                    timeInterval: self.typingTimeoutInterval,
                    target: self,
                    selector: #selector(self.stopTyping),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }

    @objc public func stopTyping() {
        queue.sync {
            self.isTyping = false
            self.typingTimeoutTimer?.invalidate()
            self.signalTypingStopped()
        }
    }

    public func signalTypingStarted() {
        self.currentUser.startedTypingIn(roomId: self.roomId) { err in
            if let error = err {
                self.currentUser.app.logger.log("Error sending typing_start event: \(error.localizedDescription)", logLevel: .debug)
            }
        }
    }

    public func signalTypingStopped() {
        self.currentUser.stoppedTypingIn(roomId: self.roomId) { err in
            if let error = err {
                self.currentUser.app.logger.log("Error sending typing_stop event: \(error.localizedDescription)", logLevel: .debug)
            }
        }
    }

}
