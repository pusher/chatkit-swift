import PusherPlatform

public class PCRoomSubscription {
    public var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription

    // TODO: This should probably be updated automatically if the app logger is updated

    public var logger: PPLogger

    let basicMessageEnricher: PCBasicMessageEnricher

    init(
        delegate: PCRoomDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        logger: PPLogger,
        basicMessageEnricher: PCBasicMessageEnricher
    ) {
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.logger = logger
        self.basicMessageEnricher = basicMessageEnricher
    }

    func handleEvent(eventId: String, headers: [String: String], data: Any) {
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

        guard let messagePayload = json["data"] as? [String: Any] else {
            self.logger.log("Missing data for room subscription event: \(json)", logLevel: .debug)
            return
        }

        do {
            let basicMessage = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)

            self.basicMessageEnricher.enrich(basicMessage) { message, err in
                guard let message = message, err == nil else {
                    self.logger.log(err!.localizedDescription, logLevel: .debug)
                    return
                }

                self.delegate?.newMessage(message)
            }
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
