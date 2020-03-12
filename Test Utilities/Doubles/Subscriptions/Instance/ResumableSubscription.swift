import XCTest
@testable import PusherChatkit

public class DummyResumableSubscription: DummyBase, ResumableSubscription {
    
    public func terminate() {
        DummyFail(sender: self, function: #function)
    }
    
}

public class StubResumableSubscription: DoubleBase, ResumableSubscription {
    
    private var terminate_expectedCallCount: UInt
    public private(set) var terminate_actualCallCount: UInt = 0
    
    public init(terminate_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.terminate_expectedCallCount = terminate_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func increment_terminate_expectedCallCount() {
        terminate_expectedCallCount += 1
    }
    
    public func terminate() {
        terminate_actualCallCount += 1
        guard terminate_actualCallCount <= terminate_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
}
