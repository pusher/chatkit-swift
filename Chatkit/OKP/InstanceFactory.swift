import class PusherPlatform.Instance


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

    typealias Dependencies = HasSDKInfoProvider
    
    let dependencies: Dependencies
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeInstance(forType instanceType: InstanceType) -> Instance {
        return PusherPlatform.Instance(locator: self.dependencies.sdkInfoProvider.locator,
                                       serviceName: self.dependencies.sdkInfoProvider.serviceName,
                                       serviceVersion: self.dependencies.sdkInfoProvider.serviceVersion,
                                       sdkInfo: self.dependencies.sdkInfoProvider.sdkInfo)
    }
    
}
