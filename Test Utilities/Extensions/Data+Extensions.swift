import XCTest

extension Data {
    
    public func toString() -> String? {
        return String(bytes: self, encoding: .utf8)
    }
    
}
