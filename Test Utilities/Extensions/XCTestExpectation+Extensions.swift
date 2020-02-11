import XCTest


extension XCTest {
    
    public enum ExpectationResult<ResultType> {
        case fulfilled(ResultType)
        case unfulfilled
    }
}

extension XCTestExpectation {
    
    public class Expectation<ResultType>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: ResultType?
        public private(set) var resultType: XCTest.ExpectationResult<ResultType> = .unfulfilled
        
        public init(description: String, systemTestTimeout: TimeInterval, nonSystemTestTimeout: TimeInterval? = nil) {
            self.timeout = Self.timeoutForCurrentTestTarget(systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function,
                                functionName: String,
                                systemTestTimeout: TimeInterval,
                                nonSystemTestTimeout: TimeInterval? = nil) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
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
        
        public init(description: String, systemTestTimeout: TimeInterval, nonSystemTestTimeout: TimeInterval? = nil) {
            self.timeout = Self.timeoutForCurrentTestTarget(systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function,
                                functionName: String,
                                systemTestTimeout: TimeInterval,
                                nonSystemTestTimeout: TimeInterval? = nil) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
        }
        
        public func handler(_ resultA: ResultTypeA, resultB: ResultTypeB) {
            let combinedResult = (resultA, resultB)
            result = combinedResult
            resultType = .fulfilled(combinedResult)
            fulfill()
        }
    }
    
    private static func timeoutForCurrentTestTarget(systemTestTimeout: TimeInterval, nonSystemTestTimeout: TimeInterval?) -> TimeInterval {
    
        let defaultNonSystemTestTimeout: TimeInterval = 1
        
        guard let testConfigurationFilePath = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"],
            testConfigurationFilePath.contains("System Tests") else {
            return nonSystemTestTimeout ?? defaultNonSystemTestTimeout
        }
        
        return systemTestTimeout
    }
    
}
