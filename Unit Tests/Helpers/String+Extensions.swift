import XCTest

extension String {
    
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
    
    // MARK: - Private methods
    
    private func toJsonAny() throws -> Any {
        return try JSONSerialization.jsonObject(with: self.toData(), options : .allowFragments)
    }
    
    private func toData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw JSONError.conversionFailed
        }
        return data
    }
    
}

// MARK: - Error handling

enum JSONError: Error {
    case conversionFailed
}
