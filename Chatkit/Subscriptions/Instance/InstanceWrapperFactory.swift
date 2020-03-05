import Foundation

protocol HasInstanceWrapperFactory {
    var instanceWrapperFactory: InstanceWrapperFactory { get }
}

protocol InstanceWrapperFactory {
    func makeInstanceWrapper(forType instanceType: InstanceType) -> InstanceWrapper
}

class ConcreteInstanceWrapperFactory: InstanceWrapperFactory {

    typealias Dependencies = HasInstanceLocator & HasSDKInfoProvider & HasTokenProvider
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeInstanceWrapper(forType instanceType: InstanceType) -> InstanceWrapper {
        return ConcreteInstanceWrapper(dependencies: dependencies)
    }
    
}
