import Foundation
import PusherChatkit

class TestingChatManagerDelegate: PCChatManagerDelegate {}

public struct TestLogger: PCLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PCLogLevel) {
        guard logLevel >= .error else { return }
        print("\(message())")
    }
}
