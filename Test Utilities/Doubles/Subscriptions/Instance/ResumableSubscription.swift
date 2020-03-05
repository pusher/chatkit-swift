import XCTest
@testable import PusherChatkit

public class DummyResumableSubscription: DummyBase, ResumableSubscription {
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    public var onOpen: (() -> Void)? {
        get {
            DummyFail(sender: self, function: #function)
            return {}
        }
        set {
            DummyFail(sender: self, function: #function)
        }
    }
    
    public var onError: ((Error) -> Void)? {
           get {
               DummyFail(sender: self, function: #function)
               return { error in () }
           }
           set {
               DummyFail(sender: self, function: #function)
           }
       }
    
    public func end() {
        DummyFail(sender: self, function: #function)
    }
    
}

public class StubResumableSubscription: DoubleBase, ResumableSubscription {
    
    // This is marked `internal` so that the `StubNetworking` wrapper can interact with it
    private var end_expectedCallCount: UInt
    public private(set) var end_actualCallCount: UInt = 0
    
    public init(end_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.end_expectedCallCount = end_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func increment_end_expectedCallCount() {
        end_expectedCallCount += 1
    }
    
    public var onOpen: (() -> Void)?
    
    public var onError: ((Error) -> Void)?
    
    public func end() {
        end_actualCallCount += 1
        guard end_actualCallCount <= end_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
}
