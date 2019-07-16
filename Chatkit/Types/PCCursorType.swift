import Foundation

public enum PCCursorType: Int {
    case read
}

extension PCCursorType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .read:
            return "read"
        }
    }
}
