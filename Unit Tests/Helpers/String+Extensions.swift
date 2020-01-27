import XCTest

extension String: Error {
    
    func toJsonData(validate: Bool = true, file: StaticString = #file, line: UInt = #line) -> Data {
        do {
            let data = try self.toData()
            if validate {
                // Verify the string is valid JSON (either a dict or an array) before returning
                _ = try toJsonAny()
            }
            return data
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
        return Data()
    }
    
    private func toJsonAny() throws -> Any {
        return try JSONSerialization.jsonObject(with: self.toData(), options : .allowFragments)
    }
    
    private func toData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw "Unable to convert String to UTF8 Data"
        }
        return data
    }
    
}
