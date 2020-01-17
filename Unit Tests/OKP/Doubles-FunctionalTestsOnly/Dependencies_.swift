import XCTest
@testable import PusherChatkit


extension ConcreteDependencies {
    
    // Allows us to test with ALL the Concrete dependencies except the InstanceFactory
    // which is exactly what we want for Functional tests
    convenience init(instanceFactory: InstanceFactory) {
        self.init(instanceLocator: "dummy:instance:locator")
        self.dependencyFactory.register(InstanceFactory.self) { dependencies in
            return instanceFactory
        }
    }
}
