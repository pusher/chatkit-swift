import XCTest
@testable import PusherChatkit

public class StubJoinedRoomsRepositoryDelegate: StubBase, JoinedRoomsRepositoryDelegate {
    
    private var didUpdateState_expectedCallCount: UInt
    public private(set) var didUpdateState_stateLastReceived: JoinedRoomsRepository.State?
    public private(set) var didUpdateState_actualCallCount: UInt = 0
    
    public init(didUpdateState_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepository.State) {
        didUpdateState_stateLastReceived = state
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_actualCallCount <= didUpdateState_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
    
}
