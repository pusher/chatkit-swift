import XCTest
@testable import PusherChatkit

// Allows us to define test doubles for Unit testing.
// If a dependency is not explicitly defined a "Dummy" version is used so that if it is interacted
// with in any way the test should fail.
public class DependenciesDoubles: StubBase, Dependencies {
    
    public let instanceLocator: InstanceLocator
    public let storeBroadcaster: StoreBroadcaster
    public let store: Store
    
    public let reducer_master: Reducer.Master.Typing.ExpressionType
    public let reducer_model_user_forInitialState: Reducer.Model.User_forInitialState.Typing.ExpressionType
    public let reducer_model_rooms_forInitialState: Reducer.Model.Rooms_forInitialState.Typing.ExpressionType
    public let reducer_model_rooms_forRemovedFromRoom: Reducer.Model.Rooms_forRemovedFromRoom.Typing.ExpressionType
    public let reducer_userSubscription_initialState: Reducer.UserSubscription.InitialState.Typing.ExpressionType
    public let reducer_userSubscription_removedFromRoom: Reducer.UserSubscription.RemovedFromRoom.Typing.ExpressionType
    
    public init(instanceLocator: InstanceLocator? = nil,
         storeBroadcaster: StoreBroadcaster? = nil,
         store: Store? = nil,
         reducer_master: Reducer.Master.Typing.ExpressionType? = nil,
         reducer_model_user_forInitialState: Reducer.Model.User_forInitialState.Typing.ExpressionType? = nil,
         reducer_model_rooms_forInitialState: Reducer.Model.Rooms_forInitialState.Typing.ExpressionType? = nil,
         reducer_model_rooms_forRemovedFromRoom: Reducer.Model.Rooms_forRemovedFromRoom.Typing.ExpressionType? = nil,
         reducer_userSubscription_initialState: Reducer.UserSubscription.InitialState.Typing.ExpressionType? = nil,
         reducer_userSubscription_removedFromRoom: Reducer.UserSubscription.RemovedFromRoom.Typing.ExpressionType? = nil,
         
         file: StaticString = #file, line: UInt = #line) {
        
        self.instanceLocator = instanceLocator ?? DummyInstanceLocator(file: file, line: line)
        self.storeBroadcaster = storeBroadcaster ?? DummyStoreBroadcaster(file: file, line: line)
        self.store = store ?? DummyStore(file: file, line: line)
        
        self.reducer_master = reducer_master ??
            DummyReducer<Reducer.Master.Typing>(file: file, line: line).reduce
        self.reducer_model_user_forInitialState = reducer_model_user_forInitialState ??
            DummyReducer<Reducer.Model.User_forInitialState.Typing>(file: file, line: line).reduce
        self.reducer_model_rooms_forInitialState = reducer_model_rooms_forInitialState ??
            DummyReducer<Reducer.Model.Rooms_forInitialState.Typing>(file: file, line: line).reduce
        self.reducer_model_rooms_forRemovedFromRoom = reducer_model_rooms_forRemovedFromRoom ??
            DummyReducer<Reducer.Model.Rooms_forRemovedFromRoom.Typing>(file: file, line: line).reduce
        self.reducer_userSubscription_initialState = reducer_userSubscription_initialState ??
            DummyReducer<Reducer.UserSubscription.InitialState.Typing>(file: file, line: line).reduce
        self.reducer_userSubscription_removedFromRoom = reducer_userSubscription_removedFromRoom ??
            DummyReducer<Reducer.UserSubscription.RemovedFromRoom.Typing>(file: file, line: line).reduce
        
        super.init(file: file, line: line)
    }
    
}