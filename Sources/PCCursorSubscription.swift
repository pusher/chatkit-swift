import Foundation
import PusherPlatform

public final class PCCursorSubscription {
    // TODO: Do we still need this?
    weak var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription
    let cursorStore: PCCursorStore
    let connectionCoordinator: PCConnectionCoordinator
    public var logger: PPLogger
    var initialStateHandler: ((Error?) -> Void)?

    init(
        delegate: PCRoomDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        cursorStore: PCCursorStore,
        connectionCoordinator: PCConnectionCoordinator,
        logger: PPLogger,
        initialStateHandler: @escaping (Error?) -> Void
    ) {
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.cursorStore = cursorStore
        self.connectionCoordinator = connectionCoordinator
        self.logger = logger
        self.initialStateHandler = initialStateHandler
    }

    deinit {
        initialStateHandler = nil
    }

    func handleEvent(eventID _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.logger.log("Event type name missing from cursor subscription event: \(json)", logLevel: .debug)
            return
        }

        guard let eventName = PCCursorEventName(rawValue: eventNameString) else {
            self.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        switch eventName {
        case .initial_state:
            parseInitialStatePayload(eventName, data: apiEventData)
        case .new_cursor:
            parseNewCursorPayload(eventName, data: apiEventData)
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}

extension PCCursorSubscription {

    fileprivate func parseInitialStatePayload(_ eventName: PCCursorEventName, data: [String: Any]) {
        guard let cursorsPayload = data["cursors"] as? [[String: Any]] else {
            let error = PCCursorsEventError.keyNotPresentInEventPayload(
                key: "cursors",
                apiEventName: eventName,
                payload: data
            )
            initialStateHandler?(error)
            return
        }

        guard cursorsPayload.count > 0 else {
            initialStateHandler?(nil)
            return
        }

        let cursorsProgressCounter = PCProgressCounter(totalCount: cursorsPayload.count, labelSuffix: "initial-state-cursors")

        cursorsPayload.forEach { cursorPayload in
            do {
                let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(cursorPayload)
                self.cursorStore.set(basicCursor)
                if cursorsProgressCounter.incrementSuccessAndCheckIfFinished() {
                    self.initialStateHandler?(nil)
                }
            } catch let err {
                self.logger.log(err.localizedDescription, logLevel: .debug)
                if cursorsProgressCounter.incrementFailedAndCheckIfFinished() {
                    self.initialStateHandler?(err)
                }
            }
        }
    }

    fileprivate func parseNewCursorPayload(_ eventName: PCCursorEventName, data: [String: Any]) {
        do {
            let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(data)
            self.cursorStore.set(basicCursor) { cursor, err in
                guard let cursor = cursor, err == nil else {
                    self.logger.log(
                        "Error when adding basic cursor to cursor store: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    return
                }

                self.logger.log("New cursor: \(cursor.debugDescription)", logLevel: .verbose)
                self.delegate?.onNewCursor(cursor)
            }
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)
            // TODO: Should we call the delegate error func?
        }
    }

}

public enum PCCursorEventName: String {
    case initial_state
    case new_cursor
}

// TODO: This is the same across all subscription classes I think
public enum PCCursorsEventError: Error {
    case keyNotPresentInEventPayload(key: String, apiEventName: PCCursorEventName, payload: [String: Any])
}

extension PCCursorsEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .keyNotPresentInEventPayload(key, apiEventName, payload):
            return "\(key) missing in \(apiEventName.rawValue) API event payload: \(payload)"
        }
    }
}
