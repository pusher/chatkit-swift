import struct PusherPlatform.PPSDKInfo


protocol Dependencies:
    HasSDKInfoProvider &
    HasStoreBroadcaster &
    HasStore &
    HasInstanceFactory &
    HasSubscriptionResponder &
    HasSubscriptionFactory &
    HasSubscriptionManager &
    HasUserService &
    HasUserHydrator
{}


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
            fatalError("Attempt to access unregistered `\(type)` dependency")
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
    
    // `override` gives tests an opportunity to override any concrete dependencies with test doubles.
    init(instanceLocator: String, override: ((DependencyFactory) -> Void)? = nil) {
        
        dependencyFactory.register(SDKInfoProvider.self, factory: { dependencies in
            return ConcreteSDKInfoProvider(locator: instanceLocator,
                                           serviceName: ServiceName.chat.rawValue,
                                           serviceVersion: ServiceVersion.version7.rawValue,
                                           sdkInfo: PPSDKInfo.current)
        })
        
        dependencyFactory.register(StoreBroadcaster.self, factory: { dependencies in
            return ConcreteStoreBroadcaster(dependencies: dependencies)
        })
        
        dependencyFactory.register(Store.self, factory: { dependencies in
            return ConcreteStore(dependencies: dependencies,
                                 delegate: self.storeBroadcaster)
        })
        
        dependencyFactory.register(InstanceFactory.self, factory: { dependencies in
            return ConcreteInstanceFactory(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionResponder.self, factory: { dependencies in
            return ConcreteSubscriptionResponder(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionFactory.self, factory: { dependencies in
            return ConcreteSubscriptionFactory(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionManager.self, factory: { dependencies in
            return ConcreteSubscriptionManager(dependencies: dependencies)
        })
        
        dependencyFactory.register(UserService.self, factory: { dependencies in
            return ConcreteUserService(dependencies: dependencies)
        })
        
        dependencyFactory.register(UserHydrator.self, factory: { dependencies in
            return ConcreteUserHydrator(dependencies: dependencies)
        })
        
        override?(dependencyFactory)
    }
    
    var sdkInfoProvider: SDKInfoProvider {
        return dependencyFactory.resolve(SDKInfoProvider.self, dependencies: self)
    }
    
    var storeBroadcaster: StoreBroadcaster {
        return dependencyFactory.resolve(StoreBroadcaster.self, dependencies: self)
    }
    
    var store: Store {
        return dependencyFactory.resolve(Store.self, dependencies: self)
    }
    
    var instanceFactory: InstanceFactory {
        return dependencyFactory.resolve(InstanceFactory.self, dependencies: self)
    }
    
    var subscriptionResponder: SubscriptionResponder {
        return dependencyFactory.resolve(SubscriptionResponder.self, dependencies: self)
    }
    
    var subscriptionFactory: SubscriptionFactory {
        return dependencyFactory.resolve(SubscriptionFactory.self, dependencies: self)
    }
    
    var subscriptionManager: SubscriptionManager {
        return dependencyFactory.resolve(SubscriptionManager.self, dependencies: self)
    }
    
    var userService: UserService {
        return dependencyFactory.resolve(UserService.self, dependencies: self)
    }
    
    var userHydrator: UserHydrator {
        return dependencyFactory.resolve(UserHydrator.self, dependencies: self)
    }
}


//class ConcreteDependencies: Dependencies {
//
//    private let instanceLocator: String
//    private let instanceFactoryOverride: InstanceFactory?
//
//    init(instanceLocator: String, instanceFactoryOverride: InstanceFactory? = nil) {
//        self.instanceLocator = instanceLocator
//        self.instanceFactoryOverride = instanceFactoryOverride
//    }
//
//    private(set) lazy var sdkInfoProvider: SDKInfoProvider = {
//        return ConcreteSDKInfoProvider(locator: instanceLocator,
//                                       serviceName: ServiceName.chat.rawValue,
//                                       serviceVersion: ServiceVersion.version7.rawValue,
//                                       sdkInfo: PPSDKInfo.current)
//    }()
//
//    private(set) lazy var storeBroadcaster: StoreBroadcaster = {
//        return ConcreteStoreBroadcaster(dependencies: self)
//    }()
//
//    private(set) lazy var store: Store = {
//        return ConcreteStore(dependencies: self,
//                             delegate: storeBroadcaster)
//    }()
//
//    private(set) lazy var instanceFactory: InstanceFactory = {
//        return instanceFactoryOverride ?? ConcreteInstanceFactory(dependencies: self)
//    }()
//
//    private(set) lazy var subscriptionResponder: SubscriptionResponder = {
//        return ConcreteSubscriptionResponder(dependencies: self)
//    }()
//
//    private(set) lazy var subscriptionFactory: SubscriptionFactory = {
//        return ConcreteSubscriptionFactory(dependencies: self)
//    }()
//
//    private(set) lazy var subscriptionManager: SubscriptionManager = {
//        return ConcreteSubscriptionManager(dependencies: self)
//    }()
//
//    private(set) lazy var userService: UserService = {
//        return ConcreteUserService(dependencies: self)
//    }()
//
//    private(set) lazy var userHydrator: UserHydrator = {
//        return ConcreteUserHydrator(dependencies: self)
//    }()
//
//}
