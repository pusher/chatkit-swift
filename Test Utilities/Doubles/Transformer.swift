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
    
    public func transform(currentState: VersionedState, previousState: VersionedState?) -> JoinedRoomsRepository.ChangeReason? {
        DummyFail(sender: self, function: #function)
        return nil
    }
    
}
