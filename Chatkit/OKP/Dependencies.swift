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
    
    // Big problem, dependencies are not cached.
    
    private var factoryClosures = [String: Any]()
    private var cachedInstances = [String: Any]()

    private func key<T>(_ type: T.Type) -> String {
        return String(reflecting: type)
    }

    public func register<T>(_ type: T.Type, factory: @escaping (Dependencies) -> T?) {
        factoryClosures[key(type)] = factory
    }

    public func unregister<T>(_ type: T.Type) {
        let key = self.key(type)
        factoryClosures[key] = nil
        cachedInstances[key] = nil
    }

    public func resolve<T>(_ type: T.Type, dependencies: Dependencies) -> T? {
        let key = self.key(type)
        
        if let cachedInstance = cachedInstances[key] as? T {
            return cachedInstance
        }
        
        guard let factoryClosure = factoryClosures[key] as? (Dependencies) -> T? else {
            return nil
        }
        
        let instance = factoryClosure(dependencies)
        cachedInstances[key] = instance
        return instance
    }
}


class ConcreteDependencies: Dependencies {
    
    let dependencyFactory = DependencyFactory()
    
    init(instanceLocator: String) {
        
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
            return ConcreteStore(dependencies: self,
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
    }
    
    var sdkInfoProvider: SDKInfoProvider {
        return dependencyFactory.resolve(SDKInfoProvider.self, dependencies: self)!
    }
    
    var storeBroadcaster: StoreBroadcaster {
        return dependencyFactory.resolve(StoreBroadcaster.self, dependencies: self)!
    }
    
    var store: Store {
        return dependencyFactory.resolve(Store.self, dependencies: self)!
    }
    
    var instanceFactory: InstanceFactory {
        return dependencyFactory.resolve(InstanceFactory.self, dependencies: self)!
    }
    
    var subscriptionResponder: SubscriptionResponder {
        return dependencyFactory.resolve(SubscriptionResponder.self, dependencies: self)!
    }
    
    var subscriptionFactory: SubscriptionFactory {
        return dependencyFactory.resolve(SubscriptionFactory.self, dependencies: self)!
    }
    
    var subscriptionManager: SubscriptionManager {
        return dependencyFactory.resolve(SubscriptionManager.self, dependencies: self)!
    }
    
    var userService: UserService {
        return dependencyFactory.resolve(UserService.self, dependencies: self)!
    }
    
    var userHydrator: UserHydrator {
        return dependencyFactory.resolve(UserHydrator.self, dependencies: self)!
    }
}
