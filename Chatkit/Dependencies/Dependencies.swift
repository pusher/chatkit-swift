import struct PusherPlatform.InstanceLocator
import protocol PusherPlatform.TokenProvider
import struct PusherPlatform.PPSDKInfo

protocol Dependencies:
    HasInstanceLocator &
    HasTokenProvider &
    HasSDKInfoProvider &
    HasStoreBroadcaster &
    HasStore &
    HasInstanceWrapperFactory &
    HasSubscriptionActionDispatcher &
    HasSubscriptionFactory &
    HasSubscriptionManager
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
    
    let instanceLocator: PusherPlatform.InstanceLocator
    let tokenProvider: TokenProvider
    
    // `override` gives tests an opportunity to override any concrete dependencies with test doubles.
    init(instanceLocator: PusherPlatform.InstanceLocator,
         tokenProvider: TokenProvider,
         override: ((DependencyFactory) -> Void)? = nil) {
        
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
        
        dependencyFactory.register(SDKInfoProvider.self, factory: { _ in
            ConcreteSDKInfoProvider(serviceName: ServiceName.chat.rawValue,
                                    serviceVersion: ServiceVersion.version7.rawValue,
                                    sdkInfo: PPSDKInfo.current)
        })
        
        dependencyFactory.register(StoreBroadcaster.self, factory: { dependencies in
            ConcreteStoreBroadcaster(dependencies: dependencies)
        })
        
        dependencyFactory.register(Store.self, factory: { dependencies in
            ConcreteStore(dependencies: dependencies,
                          delegate: self.storeBroadcaster)
        })
        
        dependencyFactory.register(InstanceWrapperFactory.self, factory: { dependencies in
            ConcreteInstanceWrapperFactory(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionActionDispatcher.self, factory: { dependencies in
            ConcreteSubscriptionActionDispatcher(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionFactory.self, factory: { dependencies in
            ConcreteSubscriptionFactory(dependencies: dependencies)
        })
        
        dependencyFactory.register(SubscriptionManager.self, factory: { dependencies in
            ConcreteSubscriptionManager(dependencies: dependencies)
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
    
    var instanceWrapperFactory: InstanceWrapperFactory {
        return dependencyFactory.resolve(InstanceWrapperFactory.self, dependencies: self)
    }
    
    var subscriptionActionDispatcher: SubscriptionActionDispatcher {
        return dependencyFactory.resolve(SubscriptionActionDispatcher.self, dependencies: self)
    }
    
    var subscriptionFactory: SubscriptionFactory {
        return dependencyFactory.resolve(SubscriptionFactory.self, dependencies: self)
    }
    
    var subscriptionManager: SubscriptionManager {
        return dependencyFactory.resolve(SubscriptionManager.self, dependencies: self)
    }
    
}
