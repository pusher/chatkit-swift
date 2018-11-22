import Foundation
import PusherPlatform

public final class PCMessageSubscription {
    public weak var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription
    public var logger: PPLogger
    let basicMessageEnricher: PCBasicMessageEnricher
    weak var chatManagerDelegate: PCChatManagerDelegate?
    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let typingIndicatorManager: PCTypingIndicatorManager
    let roomID: String

    init(
        roomID: String,
        delegate: PCRoomDelegate? = nil,
        chatManagerDelegate: PCChatManagerDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        logger: PPLogger,
        basicMessageEnricher: PCBasicMessageEnricher,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        typingIndicatorManager: PCTypingIndicatorManager
    ) {
        self.roomID = roomID
        self.delegate = delegate
        self.chatManagerDelegate = chatManagerDelegate
        self.resumableSubscription = resumableSubscription
        self.logger = logger
        self.basicMessageEnricher = basicMessageEnricher
        self.userStore = userStore
        self.roomStore = roomStore
        self.typingIndicatorManager = typingIndicatorManager
    }

    func handleEvent(eventID _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .error)
            return
        }

        guard let eventName = json["event_name"] as? String else {
            self.logger.log(
                "Event type name missing from room subscription event: \(json)",
                logLevel: .error
            )
            return
        }

        guard let eventData = json["data"] as? [String: Any] else {
            self.logger.log("Missing data for room subscription event: \(json)", logLevel: .error)
            return
        }

        switch eventName {
        case "new_message":
            onNewMessage(data: eventData)
        case "is_typing":
            onIsTyping(data: eventData)
        default:
            self.logger.log("Unknown message subscription event \(eventName)", logLevel: .error)
            return
        }
    }

    func onNewMessage(data: [String: Any]) {
        do {
            let basicMessage = try PCPayloadDeserializer.createBasicMessageFromPayload(data)

            self.basicMessageEnricher.enrich(basicMessage) { [weak self] message, err in
                guard let strongSelf = self else {
                    print("self is nil when enrichment of basicMessage has completed")
                    return
                }

                guard let message = message, err == nil else {
                    strongSelf.logger.log(err!.localizedDescription, logLevel: .debug)
                    return
                }

                strongSelf.delegate?.onMessage(message)
                strongSelf.logger.log("Room received new message: \(message.debugDescription)", logLevel: .verbose)
            }
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)

            // TODO: Should we call the delegate error func?
        }
    }

    func onIsTyping(data: [String: Any]) {
        guard let userID = data["user_id"] as? String else {
            self.logger.log(
                "user_id missing or not a string \(data)",
                logLevel: .error
            )
            return
        }

        roomStore.room(id: roomID) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when handling is_typing event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.logger.log(err!.localizedDescription, logLevel: .error)
                return
            }

            strongSelf.userStore.user(id: userID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when handling is_typing event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(err!.localizedDescription, logLevel: .error)
                    return
                }

                strongSelf.typingIndicatorManager.onIsTyping(
                    room: room,
                    user: user,
                    globalStartHook: strongSelf.chatManagerDelegate?.onUserStartedTyping,
                    globalStopHook: strongSelf.chatManagerDelegate?.onUserStoppedTyping,
                    roomStartHook: strongSelf.delegate?.onUserStartedTyping,
                    roomStopHook: strongSelf.delegate?.onUserStoppedTyping
                )
            }
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}
