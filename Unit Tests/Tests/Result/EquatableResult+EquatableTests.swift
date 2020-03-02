import XCTest
@testable import PusherChatkit

class EquatableResult_Equatable_Tests: XCTestCase {
    
    enum ErrorType: String, Error {
        case errorA = "errorA"
        case errorB = "errorB"
    }
    
    func test_equality_successVsSuccessWithSameValue_equalBothWays() {
        
        let lhs = EquatableResult<String>.success("result")
        let rhs = EquatableResult<String>.success("result")
        
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(rhs, lhs)
    }
    
    func test_equality_successVsSuccessWithDiffValue_notEqualEitherWay() {
        
        let lhs = EquatableResult<String>.success("result")
        let rhs = EquatableResult<String>.success("diff")
        
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(rhs, lhs)
    }
    
    func test_equality_successVsFailure_notEqualEitherWay() {
        
        let lhs = EquatableResult<String>.success("result")
        let rhs = EquatableResult<String>.failure(ErrorType.errorA)
        
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(rhs, lhs)
    }
    
    func test_equality_failureVsFailureWithSameError_equalBothWays() {
        
        let lhs = EquatableResult<String>.failure(ErrorType.errorA)
        let rhs = EquatableResult<String>.failure(ErrorType.errorA)
        
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(rhs, lhs)
    }
    
    func test_equality_failureVsFailureWithDifferentError_notEqualEitherWay() {
        
        let lhs = EquatableResult<String>.failure(ErrorType.errorA)
        let rhs = EquatableResult<String>.failure(ErrorType.errorB)
        
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(rhs, lhs)
    }
}
