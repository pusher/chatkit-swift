import XCTest

class DummyBase {
    
    let file: StaticString
    let line: UInt
    
    init(file: StaticString, line: UInt) {
        self.file = file
        self.line = line
    }
    
    func DummyFail<T>(sender: T, function: String) {
        XCTFail("Unexpected call to `\(function)` on `\(String(describing: sender))` object. `Dummy` object's should be never interacted with and only used to satisfy the compiler. Consider using a `Stub` instead", file: file, line: line)
    }
}
