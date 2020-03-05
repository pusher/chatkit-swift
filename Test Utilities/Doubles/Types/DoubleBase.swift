import XCTest

public class DoubleBase {
    
    let file: StaticString
    let line: UInt
    
    init(file: StaticString, line: UInt) {
        self.file = file
        self.line = line
    }
}
