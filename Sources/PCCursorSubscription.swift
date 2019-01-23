import Foundation
import PusherPlatform

public final class PCCursorSubscription {
    let resumableSubscription: PPResumableSubscription
    let cursorStore: PCCursorStore
    public var logger: PPLogger
    var onNewReadCursorHook: ((PCCursor) -> Void)?
    var initialStateHandler: ((InitialStateResult<PCCursor>) -> Void)?

    init(
        resumableSubscription: PPResumableSubscription,
        cursorStore: PCCursorStore,
        logger: PPLogger,
        onNewReadCursorHook: ((PCCursor) -> Void)? = nil,
        initialStateHandler: @escaping (InitialStateResult<PCCursor>) -> Void
    ) {
        self.resumableSubscription = resumableSubscription
        self.cursorStore = cursorStore
        self.logger = logger
        self.onNewReadCursorHook = onNewReadCursorHook
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
            let error = PCSubscriptionEventError.keyNotPresentInEventPayload(
                key: "cursors",
                eventName: eventName.rawValue,
                payload: data
            )
            initialStateHandler?(.error(error))
            return
        }

        let existingCursors = self.cursorStore.cursors.reduce(into: []) { res, cursorKeyValuePair in
            res.append(cursorKeyValuePair.value.copy())
        }
        var newCursors: [PCCursor] = []

        guard cursorsPayload.count > 0 else {
            initialStateHandler?(.success(existing: existingCursors, new: newCursors))
            return
        }

        let cursorsProgressCounter = PCProgressCounter(totalCount: cursorsPayload.count, labelSuffix: "initial-state-cursors")

        cursorsPayload.forEach { cursorPayload in
            do {
                let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(cursorPayload)
                self.cursorStore.set(basicCursor) { cursor, err in
                    if err == nil, let cursor = cursor {
                        newCursors.append(cursor)
                        if cursorsProgressCounter.incrementSuccessAndCheckIfFinished() {
                            self.initialStateHandler?(.success(existing: existingCursors, new: newCursors))
                        }
                    } else if let err = err {
                        if cursorsProgressCounter.incrementFailedAndCheckIfFinished() {
                            self.initialStateHandler?(.error(err))
                        }
                    } else {
                        if cursorsProgressCounter.incrementFailedAndCheckIfFinished() {
                            self.initialStateHandler?(.success(existing: existingCursors, new: newCursors))
                        }
                    }
                }
            } catch let err {
                self.logger.log(err.localizedDescription, logLevel: .debug)
                if cursorsProgressCounter.incrementFailedAndCheckIfFinished() {
                    self.initialStateHandler?(.error(err))
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
                self.onNewReadCursorHook?(cursor)
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
