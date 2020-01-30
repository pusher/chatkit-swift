import XCTest
@testable import PusherChatkit

// Allows us to define test doubles for Unit testing.
// If a dependency is not explicitly defined a "Dummy" version is used so that if it is interacted
// with in any way the test should fail.
public class DependenciesDoubles: StubBase, Dependencies {
    
    public let instanceLocator: InstanceLocator
    public let sdkInfoProvider: SDKInfoProvider
    public let storeBroadcaster: StoreBroadcaster
    public let store: Store
    public let instanceFactory: InstanceFactory
    public let subscriptionResponder: SubscriptionResponder
    public let subscriptionFactory: SubscriptionFactory
    public let subscriptionManager: SubscriptionManager
    public let userService: UserService
    public let missingUserFetcher: MissingUserFetcher
    
    public init(instanceLocator: InstanceLocator? = nil,
                sdkInfoProvider: SDKInfoProvider? = nil,
                storeBroadcaster: StoreBroadcaster? = nil,
                store: Store? = nil,
                instanceFactory: InstanceFactory? = nil,
                subscriptionResponder: SubscriptionResponder? = nil,
                subscriptionFactory: SubscriptionFactory? = nil,
                subscriptionManager: SubscriptionManager? = nil,
                userService: UserService? = nil,
                missingUserFetcher: MissingUserFetcher? = nil,
                
                file: StaticString = #file, line: UInt = #line) {
        
        self.instanceLocator = instanceLocator ?? DummyInstanceLocator(file: file, line: line)
        self.sdkInfoProvider = sdkInfoProvider ?? DummySDKInfoProvider(file: file, line: line)
        self.storeBroadcaster = storeBroadcaster ?? DummyStoreBroadcaster(file: file, line: line)
        self.store = store ?? DummyStore(file: file, line: line)
        self.instanceFactory = instanceFactory ?? DummyInstanceFactory(file: file, line: line)
        self.subscriptionResponder = subscriptionResponder ?? DummySubscriptionResponder(file: file, line: line)
        self.subscriptionFactory = subscriptionFactory ?? DummySubscriptionFactory(file: file, line: line)
        self.subscriptionManager = subscriptionManager ?? DummySubscriptionManager(file: file, line: line)
        self.userService = userService ?? DummyUserService(file: file, line: line)
        self.missingUserFetcher = missingUserFetcher ?? DummyMissingUserFetcher(file: file, line: line)
        
        super.init(file: file, line: line)
    }
    
}


// Allows us to test with ALL the Concrete dependencies except the InstanceFactory
// which is exactly what we want for Functional tests
extension ConcreteDependencies {
    
    public convenience init(instanceLocator: InstanceLocator, instanceFactory: InstanceFactory,
                     file: StaticString = #file, line: UInt = #line) {
        self.init(instanceLocator: instanceLocator) { dependencyFactory in
            dependencyFactory.register(InstanceFactory.self) { dependencies in
                instanceFactory
            }
        }
    }
    
    public convenience init(instanceFactory: InstanceFactory,
                     file: StaticString = #file, line: UInt = #line) {
        let instanceLocator = DummyInstanceLocator(file: file, line: line)
        self.init(instanceLocator: instanceLocator, instanceFactory: instanceFactory, file: file, line: line)
    }
    
}
