import XCTest
@testable import PusherChatkit

public class DummyTransformer: DummyBase, Transformer {
    
    public func transform(state: RoomState) -> Room {
        DummyFail(sender: self, function: #function)
        return Room(identifier: "identifier",
                    name: nil,
                    isPrivate: false,
                    unreadCount: 0,
                    lastMessageAt: nil,
                    customData: nil,
                    createdAt: Date(),
                    updatedAt: Date())
    }
    
    public func transform(currentState: VersionedState, previousState: VersionedState?) -> JoinedRoomsRepositoryChangeReason? {
        DummyFail(sender: self, function: #function)
        return nil
    }
    
}

public class StubTransformer: DoubleBase, Transformer {
    
    private let room_toReturn: Room
    private let transformState_expectedSetCallCount: UInt
    public private(set) var transformState_actualSetCallCount: UInt = 0
    
    private let changeReason_toReturn: JoinedRoomsRepositoryChangeReason?
    private let transformCurrentStatePreviousState_expectedSetCallCount: UInt
    public private(set) var transformCurrentStatePreviousState_actualSetCallCount: UInt = 0
    
    
    
    public init(room_toReturn: Room,
                changeReason_toReturn: JoinedRoomsRepositoryChangeReason? = nil,
                transformState_expectedSetCallCount: UInt = 0,
                transformCurrentStatePreviousState_expectedSetCallCount: UInt = 0,
                file: StaticString = #file, line: UInt = #line) {
        
        self.room_toReturn = room_toReturn
        self.changeReason_toReturn = changeReason_toReturn
        self.transformState_expectedSetCallCount = transformState_expectedSetCallCount
        self.transformCurrentStatePreviousState_expectedSetCallCount = transformCurrentStatePreviousState_expectedSetCallCount
        
        super.init(file: file, line: line)
    }
    
    public func transform(state: RoomState) -> Room {
        self.transformState_actualSetCallCount += 1
        
        guard self.transformState_actualSetCallCount <= self.transformState_expectedSetCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return self.room_toReturn
        }
        
        return self.room_toReturn
    }
    
    public func transform(currentState: VersionedState, previousState: VersionedState?) -> JoinedRoomsRepositoryChangeReason? {
        self.transformCurrentStatePreviousState_actualSetCallCount += 1
        
        guard self.transformCurrentStatePreviousState_actualSetCallCount <= self.transformCurrentStatePreviousState_expectedSetCallCount else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: self.file, line: self.line)
            return changeReason_toReturn
        }
        
        return self.changeReason_toReturn
    }
    
}

