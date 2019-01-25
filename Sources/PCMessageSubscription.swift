import Foundation
import PusherPlatform

public final class PCMessageSubscription {
    let roomID: String
    let resumableSubscription: PPResumableSubscription
    public var logger: PPLogger
    let basicMessageEnricher: PCBasicMessageEnricher
    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let onMessageHook: (PCMessage) -> Void
    let onIsTypingHook: (PCRoom, PCUser) -> Void

    init(
        roomID: String,
        resumableSubscription: PPResumableSubscription,
        logger: PPLogger,
        basicMessageEnricher: PCBasicMessageEnricher,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        onMessageHook: @escaping (PCMessage) -> Void,
        onIsTypingHook: @escaping (PCRoom, PCUser) -> Void
    ) {
        self.roomID = roomID
        self.resumableSubscription = resumableSubscription
        self.logger = logger
        self.basicMessageEnricher = basicMessageEnricher
        self.userStore = userStore
        self.roomStore = roomStore
        self.onMessageHook = onMessageHook
        self.onIsTypingHook = onIsTypingHook
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

                strongSelf.onMessageHook(message)
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

                strongSelf.onIsTypingHook(room, user)
            }
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}
