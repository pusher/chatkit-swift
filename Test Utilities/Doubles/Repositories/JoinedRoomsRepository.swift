import XCTest
@testable import PusherChatkit

public class StubJoinedRoomsRepository: DoubleBase, JoinedRoomsRepository {
    
    private let state_toReturn: JoinedRoomsRepositoryState
    public private(set) var state_actualCallCount: UInt = 0
    
    private let delegate_expectedSetCallCount: UInt
    public private(set) var delegate_actualSetCallCount: UInt = 0
    public weak var delegate: JoinedRoomsRepositoryDelegate? {
        didSet {
            self.delegate_actualSetCallCount += 1
            
            guard self.delegate_actualSetCallCount <= self.delegate_expectedSetCallCount else {
                XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
                return
            }
        }
    }
    
    public init(state_toReturn: JoinedRoomsRepositoryState,
                delegate_expectedSetCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.state_toReturn = state_toReturn
        self.delegate_expectedSetCallCount = delegate_expectedSetCallCount
        
        super.init(file: file, line: line)
    }
    
    public var state: JoinedRoomsRepositoryState {
        self.state_actualCallCount += 1
        return self.state_toReturn
    }
    
    public func report(_ state: JoinedRoomsRepositoryState) {
        self.delegate?.joinedRoomsRepository(self, didUpdateState: state)
    }
    
}
