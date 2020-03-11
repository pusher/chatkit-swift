import XCTest
@testable import PusherChatkit

public class StubJoinedRoomsRepository: DoubleBase, JoinedRoomsRepositoryProtocol {
    
    private let state_toReturn: JoinedRoomsRepository.State
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
    
    public init(state_toReturn: JoinedRoomsRepository.State,
                delegate_expectedSetCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.state_toReturn = state_toReturn
        self.delegate_expectedSetCallCount = delegate_expectedSetCallCount
        
        super.init(file: file, line: line)
    }
    
    public var state: JoinedRoomsRepository.State {
        self.state_actualCallCount += 1
        return self.state_toReturn
    }
    
    public func report(_ state: JoinedRoomsRepository.State) {
        let room = Room(identifier: "room-identifier",
                        name: "room-name",
                        isPrivate: false,
                        unreadCount: 10,
                        lastMessageAt: nil,
                        customData: nil,
                        createdAt: .distantPast,
                        updatedAt: .distantPast)
        
        let stubBuffer = StubBuffer(currentState_toReturn: nil, delegate_expectedSetCallCount: 1)
        let stubConnectivityMonitor = StubConnectivityMonitor(subscriptionType_toReturn: .user,
                                                              delegate_expectedSetCallCount: 1)
        let initialConnectionState: ConnectionState = .connected
        let stubTransformer = StubTransformer(room_toReturn: room, transformCurrentStatePreviousState_expectedSetCallCount: 1)
        
        let dependencies = DependenciesDoubles(transformer: stubTransformer)
        
        let joinedRoomsRepository = JoinedRoomsRepository(buffer: stubBuffer,
                                                          connectivityMonitor: stubConnectivityMonitor,
                                                          connectionState: initialConnectionState,
                                                          dependencies: dependencies)
        
        self.delegate?.joinedRoomsRepository(joinedRoomsRepository, didUpdateState: state)
    }
    
}
