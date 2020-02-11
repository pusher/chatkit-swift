import XCTest
@testable import PusherChatkit


extension XCTest {
    
    public enum ExpectationResult<ResultType> {
        case fulfilled(ResultType)
        case unfulfilled
    }
}

extension XCTestExpectation {

    // Note all properties here are computed `var`s (and not `let`s) to avoid a
    // "API violation - expectations can only be waited on once" error in the event
    // the same expectation is used twice in the same test.
    // (we often want to test two calls to `Chatkit.connect` for example)
    
    public struct Chatkit {
        
        public static var connect: Expectation<Error?> {
            .init(functionName: "connect", timeout: 15)
        }
        
        public static var createJoinedRoomsProvider: TwoArgExpectation<JoinedRoomsProvider?, Error?> {
            .init(functionName: "createJoinedRoomsProvider", timeout: 5)
        }
        
    }
    
    public struct SubscriptionManager {
        
        public static var subscribe: Expectation<VoidResult> {
            .init(functionName: "subscribe", timeout: 15)
        }
        
    }
    
    public struct JoinedRoomsProviderDelegate {
        
        public static var didJoinRoom: Expectation<Room> {
            .init(functionName: "didJoinRoom", timeout: 15)
        }
        
        public static var didLeaveRoom: Expectation<Room> {
            .init(functionName: "didLeaveRoom", timeout: 15)
        }
    }
    
    public class Expectation<ResultType>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: ResultType?
        public private(set) var resultType: XCTest.ExpectationResult<ResultType> = .unfulfilled
        
        public init(description: String, timeout: TimeInterval) {
            self.timeout = timeout
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function, functionName: String, timeout: TimeInterval) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, timeout: timeout)
        }
        
        public func handler(_ result: ResultType) {
            self.result = result
            resultType = .fulfilled(result)
            fulfill()
        }
    }
    
    public class TwoArgExpectation<ResultTypeA, ResultTypeB>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: (ResultTypeA, ResultTypeB)?
        public private(set) var resultType: XCTest.ExpectationResult<(ResultTypeA, ResultTypeB)> = .unfulfilled
        
        public init(description: String, timeout: TimeInterval) {
            self.timeout = timeout
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function,
                                functionName: String,
                                timeout: TimeInterval) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, timeout: timeout)
        }
        
        public func handler(_ resultA: ResultTypeA, resultB: ResultTypeB) {
            let combinedResult = (resultA, resultB)
            result = combinedResult
            resultType = .fulfilled(combinedResult)
            fulfill()
        }
    }
    
    
}
