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

public func XCTAssertType<ExpectedType>(_ expression: @autoclosure () throws -> Any?,  _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (ExpectedType) -> Void) {
    
    var result: Any?
    XCTAssertNoThrow(try executeAndAssignResult(expression, to: &result), message, file: file, line: line)
    
    guard let nonNilResult = result else {
        XCTFail("Expected type `\(ExpectedType.self)` but got nil value instead", file: file, line: line)
        return
    }
    guard let typedResult = nonNilResult as? ExpectedType else {
        XCTFail("Expected type `\(ExpectedType.self)` but got `\(type(of: result))` instead", file: file, line: line)
        return
    }
    validateResult(typedResult)
}

public func XCTAssertExpectationUnfulfilled<ResultType>(_ expectation: XCTestExpectation.Expectation<ResultType>, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    
    switch expectation.state {
    case let .fulfilled(result):
        XCTFail("Expected expectation to be unfulfilled but it has already become fulfilled with result: \(result). \(message)", file: file, line: line)
    case .unfulfilled:
        () // passed
    }
}

public func XCTAssertExpectationUnfulfilled<ResultTypeA, ResultTypeB>(_ expectation: XCTestExpectation.TwoArgExpectation<ResultTypeA, ResultTypeB>, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    
    switch expectation.state {
    case let .fulfilled(result):
        XCTFail("Expected expectation to be unfulfilled but it has already become fulfilled with result: \(result). \(message)", file: file, line: line)
    case .unfulfilled:
        () // passed
    }
}


public func XCTAssertExpectationFulfilled<ResultType>(_ expectation: XCTestExpectation.Expectation<ResultType>, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (ResultType) -> Void) {
    
    switch expectation.state {
    case let .fulfilled(result):
        validateResult(result)
    case .unfulfilled:
        XCTFail(message, file: file, line: line)
    }
}

public func XCTAssertExpectationFulfilled<ResultTypeA, ResultTypeB>(_ expectation: XCTestExpectation.TwoArgExpectation<ResultTypeA, ResultTypeB>, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: ((ResultTypeA, ResultTypeB)) -> Void) {
    
    switch expectation.state {
    case let .fulfilled(result):
        validateResult(result)
    case .unfulfilled:
        XCTFail(message, file: file, line: line)
    }
}

public func XCTAssertExpectationFulfilledWithResult<ResultType>(_ expectation: XCTestExpectation.Expectation<ResultType>, _ expectedResult: ResultType, _ message: String = "", file: StaticString = #file, line: UInt = #line) where ResultType : Equatable {
    
    XCTAssertExpectationFulfilled(expectation, message, file: file, line: line) { result in
        XCTAssertEqual(result, expectedResult, file: file, line: line)
    }
}

// Custom implementation speficially for a result type of <Error?>
public func XCTAssertExpectationFulfilledWithResult(_ expectation: XCTestExpectation.Expectation<Error?>, _ expectedResult: Error?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {

    XCTAssertExpectationFulfilled(expectation, message, file: file, line: line) { result in
        XCTAssertEqualError(result, expectedResult, message, file: file, line: line)
    }
}

public func XCTAssertEqualError(_ actualError: Error?, _ expectedError: Error?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    // Cast the `Error`s to `NSError` so we get Equatable behaviour
    // (Apple guarantee that Error can always be bridged to an NSError)
    XCTAssertEqual(actualError as NSError?, expectedError as NSError?, message, file: file, line: line)
}
