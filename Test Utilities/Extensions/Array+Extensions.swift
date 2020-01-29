import XCTest


extension Array {

    func next(_ index: inout Int, file: StaticString = #file, line: UInt = #line) -> Element? {
        guard index >= 0 && index < self.count else {
            XCTFail("Index out of bounds (index: \(index), array.count: \(self.count))", file: file, line: line)
            index += 1
            return nil
        }
        let element = self[index]
        index += 1
        return element
    }
    
}
