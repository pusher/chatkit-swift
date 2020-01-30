import XCTest


public func XCTAssertThrowsError<T>(_ expression: @autoclosure () throws -> T, containing: [String], file: StaticString = #file, line: UInt = #line, _ errorHandler: (Error) -> Void = { _ in }) {
    
    var thrownError: Error?
    
    XCTAssertThrowsError(expression, "", file: file, line: line) {
        thrownError = $0
    }
    
    guard let error = thrownError else {
        XCTFail("No error thrown. Expected error containing text: \"\(containing)\"")
        return
    }
    
    for search in containing {
        XCTAssertTrue(
            "\(error)".contains(search),
            "Expected error text: \"\(search)\" not contained in error: \"\(error)'\"",
            file: file, line: line
        )
    }
}


public func XCTAssertString(_ str: String?, contains search: String, file: StaticString = #file, line: UInt = #line) {
    
    guard let str = str else {
        XCTFail("Expected string containing \"\(search)\"' but got nil instead.", file: file, line: line)
        return
    }
    
    let found = str.contains(search)
    XCTAssertTrue(found, "Expected sub-string \"\(search)\"' not contained in string \"\(str)\"", file: file, line: line)
}


fileprivate func executeAndAssignResult<T>(_ expression: @autoclosure () throws -> T?, to: inout T?) rethrows {
    to = try expression()
}

fileprivate func executeAndAssignEquatableResult<T>(_ expression: @autoclosure () throws -> T?, to: inout T?) rethrows where T : Equatable {
    to = try expression()
}

public func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (T) -> Void) {
    
    var result: T?
    
    XCTAssertNoThrow(try executeAndAssignResult(expression, to: &result), message, file: file, line: line)
    
    if let result = result {
        validateResult(result)
    }
}

public func XCTAssertNotNil<T>(_ expression: @autoclosure () throws -> T?, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (T) -> Void) {
    
    var result: T?
    
    XCTAssertNoThrow(try executeAndAssignResult(expression, to: &result), message, file: file, line: line)
    XCTAssertNotNil(result, message, file: file, line: line)
    
    if let result = result {
        validateResult(result)
    }
}

public func XCTAssertEqual<T>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: () -> Void) where T : Equatable {

//    XCTAssertEqual(try executeAndAssignEquatableResult(expression1, to: &result),
    
    XCTAssertEqual(try expression1(),
                   try expression2(), message, file: file, line: line)

    let result1 = try? expression1()
    let result2 = try? expression2()
    
    if result1 == result2 {
        validateResult()
    }
}
