import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    public var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription
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

    func handleEvent(eventId _: String, headers _: [String: String], data: Any) {
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

            self.basicMessageEnricher.enrich(basicMessage) { [weak self] message, err in
                guard let strongSelf = self else {
                    print("self is nil when enrichment of basicMessage has completed")
                    return
                }

                guard let message = message, err == nil else {
                    strongSelf.logger.log(err!.localizedDescription, logLevel: .debug)
                    return
                }

                strongSelf.delegate?.newMessage(message: message)
                strongSelf.logger.log("Room received new message: \(message.text)", logLevel: .verbose)
            }
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)

            // TODO: Should we call the delegate error func?
        }
    }
}
