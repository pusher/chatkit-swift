import XCTest
@testable import PusherChatkit

public class StubConnectivityMonitor: DoubleBase, ConnectivityMonitor {
    
    private let subscriptionType_toReturn: SubscriptionType
    public private(set) var subscriptionType_actualCallCount: UInt = 0
    
    private let delegate_expectedSetCallCount: UInt
    public private(set) var delegate_actualSetCallCount: UInt = 0
    public weak var delegate: ConnectivityMonitorDelegate? {
        didSet {
            self.delegate_actualSetCallCount += 1
            
            guard self.delegate_actualSetCallCount <= self.delegate_expectedSetCallCount else {
                XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
                return
            }
        }
    }
    
    public init(subscriptionType_toReturn: SubscriptionType,
                delegate_expectedSetCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.subscriptionType_toReturn = subscriptionType_toReturn
        self.delegate_expectedSetCallCount = delegate_expectedSetCallCount
        
        super.init(file: file, line: line)
    }
    
    public var subscriptionType: SubscriptionType {
        self.subscriptionType_actualCallCount += 1
        return self.subscriptionType_toReturn
    }
    
    public func store(_ store: Store, didUpdateState state: VersionedState) {}
    
    public func report(_ state: ConnectionState) {
        self.delegate?.connectivityMonitor(self, didUpdateConnectionState: state)
    }
    
}
