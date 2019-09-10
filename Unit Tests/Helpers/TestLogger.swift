import Foundation
import PusherPlatform

class TestLogger: PPLogger {
    
    // MARK: - PPLogger
    
    func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
    }
    
}
