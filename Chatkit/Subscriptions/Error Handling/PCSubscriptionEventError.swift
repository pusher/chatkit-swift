import Foundation

public enum PCSubscriptionEventError: Error {
    case keyNotPresentInEventPayload(key: String, eventName: String, payload: [String: Any])
}

extension PCSubscriptionEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .keyNotPresentInEventPayload(key, apiEventName, payload):
            return "\(key) missing in \(apiEventName) subscription event payload: \(payload)"
        }
    }
}
