import struct PusherPlatform.PPSDKInfo

protocol Dependencies:
    HasInstanceLocator &
    HasStore &
    HasTransformer &
    HasMasterReducer &
    HasUserReducer &
    HasRoomListReducer &
    HasUserSubscriptionInitialStateReducer &
    HasUserSubscriptionAddedToRoomReducer &
    HasUserSubscriptionRemovedFromRoomReducer &
    HasUserSubscriptionRoomUpdatedReducer &
    HasUserSubscriptionRoomDeletedReducer &
    HasUserSubscriptionReadStateUpdatedReducer &
    HasSubscriptionStateUpdatedReducer
{}

typealias NoDependencies = Any

class DependencyFactory {
    
    // MARK: - Types
    
    typealias Factory<T> = (Dependencies) -> T
 
    private enum DependencyState<T> {
        case registered(Factory<T>)
        case initialised(T)
    }
 
    private var dependencyStates = [String: Any]()
    
    // MARK: - Public

    func register<T>(_ type: T.Type, factory: @escaping Factory<T>) {
        dependencyStates[key(type)] = DependencyState<T>.registered(factory)
    }

    func unregister<T>(_ type: T.Type) {
        dependencyStates[key(type)] = nil
    }

    func resolve<T>(_ type: T.Type, dependencies: Dependencies) -> T {
        let key = self.key(type)
        
        guard let dependencyState = dependencyStates[key] as? DependencyState<T> else {
            preconditionFailure("Attempt to access unregistered `\(type)` dependency")
        }
        
        switch dependencyState {

        case let .registered(factoryClosure):
            let dependency = factoryClosure(dependencies)
            dependencyStates[key] = DependencyState<T>.initialised(dependency)
            return dependency
            
        case let .initialised(dependency):
            return dependency
            
        }
    }
    
    // MARK: - Private
    
    private func key<T>(_ type: T.Type) -> String {
        return String(reflecting: type)
    }
}

class ConcreteDependencies: Dependencies {
    
    private let dependencyFactory = DependencyFactory()
    
    let instanceLocator: InstanceLocator
    
    let masterReducer = Reducer.Master.reduce
    let userReducer = Reducer.Model.User.reduce
    let roomListReducer = Reducer.Model.RoomList.reduce
    let initialStateUserSubscriptionReducer = Reducer.UserSubscription.InitialState.reduce
    let userSubscriptionAddedToRoomReducer = Reducer.UserSubscription.AddedToRoom.reduce
    let userSubscriptionRemovedFromRoomReducer = Reducer.UserSubscription.RemovedFromRoom.reduce
    let userSubscriptionRoomUpdatedReducer = Reducer.UserSubscription.RoomUpdated.reduce
    let userSubscriptionRoomDeletedReducer = Reducer.UserSubscription.RoomDeleted.reduce
    let userSubscriptionReadStateUpdatedReducer = Reducer.UserSubscription.ReadStateUpdated.reduce
    let subscriptionStateUpdatedReducer = Reducer.Subscription.StateUpdated.reduce
    
    // `override` gives tests an opportunity to override any concrete dependencies with test doubles.
    init(instanceLocator: InstanceLocator, override: ((DependencyFactory) -> Void)? = nil) {
        
        self.instanceLocator = instanceLocator
        
        dependencyFactory.register(Store.self, factory: { dependencies in
            ConcreteStore(dependencies: dependencies)
        })
        
        dependencyFactory.register(Transformer.self, factory: { _ in
            ConcreteTransformer()
        })
        
        override?(dependencyFactory)
    }
    
    var store: Store {
        return dependencyFactory.resolve(Store.self, dependencies: self)
    }
    
    var transformer: Transformer {
        return dependencyFactory.resolve(Transformer.self, dependencies: self)
    }
    
}
