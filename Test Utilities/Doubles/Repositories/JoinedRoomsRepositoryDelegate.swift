import XCTest
@testable import PusherChatkit

public class StubJoinedRoomsRepositoryDelegate: DoubleBase, JoinedRoomsRepositoryDelegate {
    
    public typealias DidUpdateState = (JoinedRoomsRepositoryState) -> Void
    
    private var didUpdateState_expectedCallCount: UInt
    private var didUpdateState_handler: DidUpdateState?
    public private(set) var didUpdateState_stateLastReceived: JoinedRoomsRepositoryState?
    public private(set) var didUpdateState_actualCallCount: UInt = 0
    
    public init(didUpdateState_expectedCallCount: UInt = 0,
                didUpdateState_handler: DidUpdateState? = nil,
                file: StaticString = #file, line: UInt = #line) {
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        self.didUpdateState_handler = didUpdateState_handler
        
        super.init(file: file, line: line)
    }
    
    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepositoryState) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_actualCallCount <= didUpdateState_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        
        didUpdateState_handler?(state)
    }
    
}
