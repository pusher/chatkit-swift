import XCTest
@testable import PusherChatkit

public class StubBuffer: DoubleBase, Buffer {
    
    private let currentState_toReturn: VersionedState?
    public private(set) var currentState_actualCallCount: UInt = 0
    
    private let filter_toReturn: StateFilter
    public private(set) var filter_actualCallCount: UInt = 0
    
    private let delegate_expectedSetCallCount: UInt
    public private(set) var delegate_actualSetCallCount: UInt = 0
    public weak var delegate: BufferDelegate? {
        didSet {
            self.delegate_actualSetCallCount += 1
            
            guard self.delegate_actualSetCallCount <= self.delegate_expectedSetCallCount else {
                XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
                return
            }
        }
    }
    
    public init(currentState_toReturn: VersionedState?,
                filter_toReturn: StateFilter,
                delegate_expectedSetCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.currentState_toReturn = currentState_toReturn
        self.filter_toReturn = filter_toReturn
        self.delegate_expectedSetCallCount = delegate_expectedSetCallCount
        
        super.init(file: file, line: line)
    }
    
    public var currentState: VersionedState? {
        self.currentState_actualCallCount += 1
        return self.currentState_toReturn
    }
    
    public var filter: StateFilter {
        self.filter_actualCallCount += 1
        return self.filter_toReturn
    }
    
    public func store(_ store: Store, didUpdateState state: VersionedState) {}
    
    public func report(_ state: VersionedState) {
        self.delegate?.buffer(self, didUpdateState: state)
    }
    
}
