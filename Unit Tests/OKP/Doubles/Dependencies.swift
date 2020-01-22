import XCTest
@testable import PusherChatkit


class DependenciesDoubles: StubBase, Dependencies {
    
    let sdkInfoProvider: SDKInfoProvider
    let storeBroadcaster: StoreBroadcaster
    let store: Store
    let instanceFactory: InstanceFactory
    let subscriptionResponder: SubscriptionResponder
    let subscriptionFactory: SubscriptionFactory
    let subscriptionManager: SubscriptionManager
    let userService: UserService
    let missingUserFetcher: MissingUserFetcher
    
    init(sdkInfoProvider: SDKInfoProvider? = nil,
         storeBroadcaster: StoreBroadcaster? = nil,
         store: Store? = nil,
         instanceFactory: InstanceFactory? = nil,
         subscriptionResponder: SubscriptionResponder? = nil,
         subscriptionFactory: SubscriptionFactory? = nil,
         subscriptionManager: SubscriptionManager? = nil,
         userService: UserService? = nil,
         missingUserFetcher: MissingUserFetcher? = nil,
         
         file: StaticString = #file, line: UInt = #line) {
        
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
