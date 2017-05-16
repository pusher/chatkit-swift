import PusherPlatform

// TODO: Should this have the delegate or the PCRoom itself?

// TODO: Make Room able to handle sending events to main delegate or Room delegate
//
// e.g. _internalDelegate (goes to PCUserSubscription delegate) or delegate, if set

public class PCRoomSubscription {
    public var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription

    // TODO: This should probably be updated automatically if the app logger is updated

    public var logger: PPLogger

    public init(
        delegate: PCRoomDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        logger: PPLogger
    ) {
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.logger = logger
    }

    public func handleEvent(eventId: String, headers: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventTypeName = json["event_name"] as? String else {
            self.logger.log("Event type name missing from room subscription event: \(json)", logLevel: .debug)
            return
        }

        let expectedEventTypeName = "new_message"

        guard eventTypeName == expectedEventTypeName else {
            self.logger.log("Expected event type name to be \(expectedEventTypeName) but got \(eventTypeName)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.logger.log("Missing data for room subscription event: \(json)", logLevel: .debug)
            return
        }

        guard let messagePayload = apiEventData["message"] as? [String: Any] else {
            self.logger.log("Missing message key for room subscription event: \(json)", logLevel: .debug)
            return
        }

        do {
            let message = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
            self.delegate?.newMessage(message)
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)
//            self.delegate?.error(err)
        }
    }
}

public enum  PCRoomSubscriptionError: Error {
    case failedToFetchInitialStateForRoomSubscription
}

// TOOD: LocalizedError
