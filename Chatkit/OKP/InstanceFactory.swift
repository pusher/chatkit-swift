import Foundation

protocol HasInstanceFactory {
    var instanceFactory: InstanceFactory { get }
}

enum InstanceType {
    case subscription(SubscriptionType)
    case service(ServiceType)
}

extension InstanceType: Hashable {}

protocol InstanceFactory {
    func makeInstance(forType instanceType: InstanceType) -> Instance
}

class ConcreteInstanceFactory: InstanceFactory {

    typealias Dependencies = HasInstanceLocator & HasSDKInfoProvider & HasTokenProvider
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeInstance(forType instanceType: InstanceType) -> Instance {
        return ConcreteInstance(dependencies: self.dependencies)
    }
    
}
