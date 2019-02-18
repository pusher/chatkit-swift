import Foundation
import PusherPlatform

public final class PCMultipartMessageSubscription {
    let roomID: String
    let resumableSubscription: PPResumableSubscription
    public var logger: PPLogger
    let multipartMessageEnricher: PCMultipartBasicMessageEnricher
    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let onMessageHook: (PCMultipartMessage) -> Void
    let onIsTypingHook: (PCRoom, PCUser) -> Void
    
    init(
        roomID: String,
        resumableSubscription: PPResumableSubscription,
        logger: PPLogger,
        multipartMessageEnricher: PCMultipartBasicMessageEnricher,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        onMessageHook: @escaping (PCMultipartMessage) -> Void,
        onIsTypingHook: @escaping (PCRoom, PCUser) -> Void
    ) {
        self.roomID = roomID
        self.resumableSubscription = resumableSubscription
        self.logger = logger
        self.multipartMessageEnricher = multipartMessageEnricher
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
            let multipartMessage = try PCPayloadDeserializer.createMultipartMessageFromPayload(data)
            self.multipartMessageEnricher.enrich(multipartMessage) { [weak self] message, err in
                guard let strongSelf = self else {
                    print("self is nil when enrichment of multipartMessage has completed")
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
