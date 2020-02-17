import XCTest
import struct PusherPlatform.InstanceLocator
import protocol PusherPlatform.TokenProvider
@testable import PusherChatkit

private let defaultInstanceLocator = PusherPlatform.InstanceLocator(string: "dummy_version:dummy_region:dummy_location")!

// Allows us to define test doubles for Unit testing.
// If a dependency is not explicitly defined a "Dummy" version is used so that if it is interacted
// with in any way the test should fail.
public class DependenciesDoubles: DoubleBase, Dependencies {
    
    public let instanceLocator: PusherPlatform.InstanceLocator
    public let tokenProvider: PusherPlatform.TokenProvider
    public let sdkInfoProvider: SDKInfoProvider
    public let storeBroadcaster: StoreBroadcaster
    public let store: Store
    public let instanceWrapperFactory: InstanceWrapperFactory
    public let subscriptionActionDispatcher: SubscriptionActionDispatcher
    public let subscriptionFactory: SubscriptionFactory
    public let subscriptionManager: SubscriptionManager
    
    public let masterReducer: Reducer.Master.ExpressionType
    public let userReducer: Reducer.Model.User.ExpressionType
    public let roomListReducer: Reducer.Model.RoomList.ExpressionType
    public let initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType
    public let userSubscriptionAddedToRoomReducer: Reducer.UserSubscription.AddedToRoom.ExpressionType
    public let userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType
    public let userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType
    public let userSubscriptionRoomDeletedReducer: Reducer.UserSubscription.RoomDeleted.ExpressionType
    public let userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType
    
    public init(instanceLocator: PusherPlatform.InstanceLocator? = nil,
                tokenProvider: PusherPlatform.TokenProvider? = nil,
                sdkInfoProvider: SDKInfoProvider? = nil,
                storeBroadcaster: StoreBroadcaster? = nil,
                store: Store? = nil,
                instanceWrapperFactory: InstanceWrapperFactory? = nil,
                subscriptionActionDispatcher: SubscriptionActionDispatcher? = nil,
                subscriptionFactory: SubscriptionFactory? = nil,
                subscriptionManager: SubscriptionManager? = nil,
                masterReducer: Reducer.Master.ExpressionType? = nil,
                userReducer: Reducer.Model.User.ExpressionType? = nil,
                roomListReducer: Reducer.Model.RoomList.ExpressionType? = nil,
                initialStateUserSubscriptionReducer: Reducer.UserSubscription.InitialState.ExpressionType? = nil,
                userSubscriptionAddedToRoomReducer: Reducer.UserSubscription.AddedToRoom.ExpressionType? = nil,
                userSubscriptionRemovedFromRoomReducer: Reducer.UserSubscription.RemovedFromRoom.ExpressionType? = nil,
                userSubscriptionRoomUpdatedReducer: Reducer.UserSubscription.RoomUpdated.ExpressionType? = nil,
                userSubscriptionRoomDeletedReducer: Reducer.UserSubscription.RoomDeleted.ExpressionType? = nil,
                userSubscriptionReadStateUpdatedReducer: Reducer.UserSubscription.ReadStateUpdated.ExpressionType? = nil,
                
                file: StaticString = #file, line: UInt = #line) {
        
        self.instanceLocator = instanceLocator ?? defaultInstanceLocator
        self.tokenProvider = tokenProvider ?? DummyTokenProvider(file: file, line: line)
        self.sdkInfoProvider = sdkInfoProvider ?? DummySDKInfoProvider(file: file, line: line)
        self.storeBroadcaster = storeBroadcaster ?? DummyStoreBroadcaster(file: file, line: line)
        self.store = store ?? DummyStore(file: file, line: line)
        self.instanceWrapperFactory = instanceWrapperFactory ?? DummyInstanceWrapperFactory(file: file, line: line)
        self.subscriptionActionDispatcher = subscriptionActionDispatcher ?? DummySubscriptionActionDispatcher(file: file, line: line)
        self.subscriptionFactory = subscriptionFactory ?? DummySubscriptionFactory(file: file, line: line)
        self.subscriptionManager = subscriptionManager ?? DummySubscriptionManager(file: file, line: line)
        
        self.masterReducer = masterReducer ??
            DummyReducer<Reducer.Master>(file: file, line: line).reduce
        self.userReducer = userReducer ??
            DummyReducer<Reducer.Model.User>(file: file, line: line).reduce
        self.roomListReducer = roomListReducer ??
            DummyReducer<Reducer.Model.RoomList>(file: file, line: line).reduce
        self.initialStateUserSubscriptionReducer = initialStateUserSubscriptionReducer ??
            DummyReducer<Reducer.UserSubscription.InitialState>(file: file, line: line).reduce
        self.userSubscriptionAddedToRoomReducer = userSubscriptionAddedToRoomReducer ??
            DummyReducer<Reducer.UserSubscription.AddedToRoom>(file: file, line: line).reduce
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

// Allows us to test with ALL the Concrete dependencies except the InstanceWrapperFactory
// which is exactly what we want for Functional tests
extension ConcreteDependencies {
    
    public convenience init(instanceLocator: InstanceLocator? = nil,
                            tokenProvider: TokenProvider? = nil,
                            instanceWrapperFactory: InstanceWrapperFactory,
                            file: StaticString = #file, line: UInt = #line) {
        
        let instanceLocator = instanceLocator ?? defaultInstanceLocator
        let tokenProvider = tokenProvider ?? DummyTokenProvider(file: file, line: line)
        
        self.init(instanceLocator: instanceLocator, tokenProvider: tokenProvider) { dependencyFactory in
            dependencyFactory.register(InstanceWrapperFactory.self) { _ in
                instanceWrapperFactory
            }
        }
    }
    
}
