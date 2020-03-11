import Foundation
import PusherPlatform

public class TestLogger: PPLogger {
    
    public init() {}
    
    // MARK: - PPLogger
    
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
    }
    
}
