import XCTest
@testable import PusherChatkit

public class DummyConnectivityMonitorDelegate: DummyBase, ConnectivityMonitorDelegate {
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    public func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState) {
        DummyFail(sender: self, function: #function)
    }
}

public class StubConnectivityMonitorDelegate: StubBase, ConnectivityMonitorDelegate {
    
    private var didUpdateState_expectedCallCount: UInt
    public private(set) var didUpdateState_stateLastReceived: ConnectionState?
    public private(set) var didUpdateState_actualCallCount: UInt = 0
    
    public init(didUpdateState_expectedCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        self.didUpdateState_expectedCallCount = didUpdateState_expectedCallCount
        
        super.init(file: file, line: line)
    }
    
    public func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState) {
        didUpdateState_stateLastReceived = connectionState
        didUpdateState_actualCallCount += 1
        
        guard didUpdateState_actualCallCount <= didUpdateState_expectedCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
    }
    
}
