import struct PusherPlatform.PPSDKInfo

protocol Dependencies:
    HasInstanceLocator &
    HasStoreBroadcaster &
    HasStore &
    HasReductionManager
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
    
    let instanceLocator: InstanceLocator
    
    // `override` gives tests an opportunity to override any concrete dependencies with test doubles.
    init(instanceLocator: InstanceLocator, override: ((DependencyFactory) -> Void)? = nil) {
        
        self.instanceLocator = instanceLocator
        
        dependencyFactory.register(StoreBroadcaster.self, factory: { dependencies in
            ConcreteStoreBroadcaster(dependencies: dependencies)
        })
        
        dependencyFactory.register(Store.self, factory: { dependencies in
            ConcreteStore(dependencies: dependencies,
                          delegate: self.storeBroadcaster)
        })
        
        override?(dependencyFactory)
    }
    
    var storeBroadcaster: StoreBroadcaster {
        return dependencyFactory.resolve(StoreBroadcaster.self, dependencies: self)
    }
    
    var store: Store {
        return dependencyFactory.resolve(Store.self, dependencies: self)
    }
    
    var reductionManager: ReductionManager {
        return dependencyFactory.resolve(ReductionManager.self, dependencies: self)
    }
    
}
