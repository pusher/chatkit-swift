import XCTest
@testable import PusherChatkit


let DummyInstanceLocator = "dummy:instance:locator"

extension ConcreteDependencies {
    
    // Allows us to test with ALL the Concrete dependencies except the InstanceFactory
    // which is exactly what we want for Functional tests
    
    convenience init(instanceLocator: String, instanceFactory: InstanceFactory) {
        
        self.init(instanceLocator: instanceLocator) { dependencyFactory in

            dependencyFactory.register(InstanceFactory.self) { dependencies in
                return instanceFactory
            }
        }
        
    }
    
    convenience init(instanceFactory: InstanceFactory) {
        self.init(instanceLocator: DummyInstanceLocator, instanceFactory: instanceFactory)
    }
    
}
