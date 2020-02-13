import XCTest
@testable import PusherChatkit

// Allows us to define test doubles for Unit testing.
// If a dependency is not explicitly defined a "Dummy" version is used so that if it is interacted
// with in any way the test should fail.
public class DependenciesDoubles: StubBase, Dependencies {
    
    public let instanceLocator: InstanceLocator
    public let storeBroadcaster: StoreBroadcaster
    public let store: Store
    
    public let masterReducer: Reducer.Master.ExpressionType
    public let userReducer: Reducer.Model.User.ExpressionType
    public let roomListReducer: Reducer.Model.RoomList.ExpressionType
    public let initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType
    public let userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType
    public let userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType
    public let userSubscriptionRoomDeletedReducer: Reducer.UserSubscription.RoomDeleted.ExpressionType
    public let userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType
    
    public init(instanceLocator: InstanceLocator? = nil,
                storeBroadcaster: StoreBroadcaster? = nil,
                store: Store? = nil,
                masterReducer: Reducer.Master.ExpressionType? = nil,
                userReducer: Reducer.Model.User.ExpressionType? = nil,
                roomListReducer: Reducer.Model.RoomList.ExpressionType? = nil,
                initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType? = nil,
                userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType? = nil,
                userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType? = nil,
                userSubscriptionRoomDeletedReducer: Reducer.UserSubscription.RoomDeleted.ExpressionType? = nil,
                userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType? = nil,
                
                file: StaticString = #file, line: UInt = #line) {
        
        self.instanceLocator = instanceLocator ?? DummyInstanceLocator(file: file, line: line)
        self.storeBroadcaster = storeBroadcaster ?? DummyStoreBroadcaster(file: file, line: line)
        self.store = store ?? DummyStore(file: file, line: line)
        
        self.masterReducer = masterReducer ??
            DummyReducer<Reducer.Master>(file: file, line: line).reduce
        self.userReducer = userReducer ??
            DummyReducer<Reducer.Model.User>(file: file, line: line).reduce
        self.roomListReducer = roomListReducer ??
            DummyReducer<Reducer.Model.RoomList>(file: file, line: line).reduce
        self.initialStateUserSubscriptionReducer = initialStateUserSubscriptionReducer ??
            DummyReducer<Reducer.UserSubscription.InitialState>(file: file, line: line).reduce
        self.userSubscriptionRemovedFromRoomReducer = userSubscriptionRemovedFromRoomReducer ??
            DummyReducer<Reducer.UserSubscription.RemovedFromRoom>(file: file, line: line).reduce
        self.userSubscriptionRoomUpdatedReducer = userSubscriptionRoomUpdatedReducer ??
            DummyReducer<Reducer.UserSubscription.RoomUpdated>(file: file, line: line).reduce
        self.userSubscriptionRoomDeletedReducer = userSubscriptionRoomDeletedReducer ??
            DummyReducer<Reducer.UserSubscription.RoomDeleted>(file: file, line: line).reduce
        self.userSubscriptionReadStateUpdatedReducer = userSubscriptionReadStateUpdatedReducer ??
            DummyReducer<Reducer.UserSubscription.ReadStateUpdated>(file: file, line: line).reduce
        
        super.init(file: file, line: line)
    }
    
}
