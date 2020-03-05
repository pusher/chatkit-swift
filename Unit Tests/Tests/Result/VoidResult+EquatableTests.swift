import XCTest
@testable import PusherChatkit

class VoidResult_Equatable_Tests: XCTestCase {
    
    enum ErrorType: String, Error {
        case errorA = "errorA"
        case errorB = "errorB"
    }
    
    func test_equality_successVsSuccess_equalBothWays() {
        
        let lhs = VoidResult.success
        let rhs = VoidResult.success
        
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(rhs, lhs)
    }
    
    func test_equality_successVsFailure_notEqualEitherWay() {
        
        let lhs = VoidResult.success
        let rhs = VoidResult.failure(ErrorType.errorA)
        
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(rhs, lhs)
    }
    
    func test_equality_failureVsFailureWithSameError_equalBothWays() {
        
        let lhs = VoidResult.failure(ErrorType.errorA)
        let rhs = VoidResult.failure(ErrorType.errorA)
        
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(rhs, lhs)
    }
    
    func test_equality_failureVsFailureWithDifferentError_notEqualEitherWay() {
        
        let lhs = VoidResult.failure(ErrorType.errorA)
        let rhs = VoidResult.failure(ErrorType.errorB)
        
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(rhs, lhs)
    }
}
