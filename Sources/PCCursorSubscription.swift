import Foundation
import PusherPlatform

public final class PCCursorSubscription {
    public var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription
    let basicCursorEnricher: PCBasicCursorEnricher
    let handleCursorSet: (PCBasicCursor) -> Void
    public var logger: PPLogger

    init(
        delegate: PCRoomDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        basicCursorEnricher: PCBasicCursorEnricher,
        handleCursorSet: @escaping (PCBasicCursor) -> Void,
        logger: PPLogger
    ) {
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.basicCursorEnricher = basicCursorEnricher
        self.handleCursorSet = handleCursorSet
        self.logger = logger
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

        let expectedEventTypeName = "cursor_set"

        guard eventTypeName == expectedEventTypeName else {
            self.logger.log("Expected event type name to be \(expectedEventTypeName) but got \(eventTypeName)", logLevel: .debug)
            return
        }

        guard let basicCursorPayload = json["data"] as? [String: Any] else {
            self.logger.log("Missing data for cursor subscription event: \(json)", logLevel: .debug)
            return
        }

        do {
            let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(basicCursorPayload)
            self.handleCursorSet(basicCursor)

            self.basicCursorEnricher.enrich(basicCursor) { [weak self] cursor, err in
                guard let strongSelf = self else {
                    print("self is nil when enrichment of basicCursor has completed")
                    return
                }

                guard let cursor = cursor, err == nil else {
                    strongSelf.logger.log(err!.localizedDescription, logLevel: .debug)
                    return
                }

                strongSelf.delegate?.cursorSet(cursor: cursor)
                strongSelf.logger.log("Cursor set: \(cursor.debugDescription)", logLevel: .verbose)
            }
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)
            // TODO: Should we call the delegate error func?
        }
    }
}
