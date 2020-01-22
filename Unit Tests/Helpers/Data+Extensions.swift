import XCTest

extension Data {
    
    func toString() -> String? {
        return String(bytes: self, encoding: .utf8)
    }
    
}
