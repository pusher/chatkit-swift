import XCTest

extension XCTestExpectation {
    
    public enum ExpectationState<ResultType> {
        case fulfilled(ResultType)
        case unfulfilled
    }
    
    public class Expectation<ResultType>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: ResultType?
        public private(set) var state: ExpectationState<ResultType> = .unfulfilled
        
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
            state = .fulfilled(result)
            fulfill()
        }
    }
    
    public class TwoArgExpectation<ResultTypeA, ResultTypeB>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: (ResultTypeA, ResultTypeB)?
        public private(set) var state: ExpectationState<(ResultTypeA, ResultTypeB)> = .unfulfilled
        
        public init(description: String, systemTestTimeout: TimeInterval? = nil, nonSystemTestTimeout: TimeInterval? = nil) {
            self.timeout = Self.timeoutForCurrentTestTarget(systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function,
                                functionName: String,
                                systemTestTimeout: TimeInterval? = nil,
                                nonSystemTestTimeout: TimeInterval? = nil) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
        }
        
        public func handler(_ resultA: ResultTypeA, resultB: ResultTypeB) {
            let combinedResult = (resultA, resultB)
            result = combinedResult
            state = .fulfilled(combinedResult)
            fulfill()
        }
    }
    
    public class ThreeArgExpectation<ResultTypeA, ResultTypeB, ResultTypeC>: XCTestExpectation {
        
        public let timeout: TimeInterval
        public private(set) var result: (ResultTypeA, ResultTypeB, ResultTypeC)?
        public private(set) var state: ExpectationState<(ResultTypeA, ResultTypeB, ResultTypeC)> = .unfulfilled
        
        public init(description: String, systemTestTimeout: TimeInterval?, nonSystemTestTimeout: TimeInterval? = nil) {
            self.timeout = Self.timeoutForCurrentTestTarget(systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
            super.init(description: description)
        }
        
        public convenience init(forClassName className: String = #function,
                                functionName: String,
                                systemTestTimeout: TimeInterval? = nil,
                                nonSystemTestTimeout: TimeInterval? = nil) {
            let description = "`\(className).\(functionName)` handler should be invoked"
            self.init(description: description, systemTestTimeout: systemTestTimeout, nonSystemTestTimeout: nonSystemTestTimeout)
        }
        
        public func handler(_ resultA: ResultTypeA, resultB: ResultTypeB, resultC: ResultTypeC) {
            let combinedResult = (resultA, resultB, resultC)
            result = combinedResult
            state = .fulfilled(combinedResult)
            fulfill()
        }
    }
    
    private static func timeoutForCurrentTestTarget(systemTestTimeout: TimeInterval?, nonSystemTestTimeout: TimeInterval?) -> TimeInterval {
    
        let defaultNonSystemTestTimeout: TimeInterval = 1
        
        guard let testConfigurationFilePath = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"],
            testConfigurationFilePath.contains("System Tests") else {
            return nonSystemTestTimeout ?? defaultNonSystemTestTimeout
        }
        
        return systemTestTimeout ?? defaultNonSystemTestTimeout
    }
    
    public func fulfill(after timeInterval: TimeInterval, queue: DispatchQueue = .main) {
        queue.asyncAfter(deadline: .now() + timeInterval) {
            self.fulfill()
        }
    }
    
}
