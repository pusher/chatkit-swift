import XCTest
@testable import PusherChatkit

// Allows us to define test doubles for Unit testing.
// If a dependency is not explicitly defined a "Dummy" version is used so that if it is interacted
// with in any way the test should fail.
class DependenciesDoubles: StubBase, Dependencies {
    
    let instanceLocator: InstanceLocator
    let storeBroadcaster: StoreBroadcaster
    let store: Store
    
    init(instanceLocator: InstanceLocator? = nil,
         storeBroadcaster: StoreBroadcaster? = nil,
         store: Store? = nil,
         
         file: StaticString = #file, line: UInt = #line) {
        
        self.instanceLocator = instanceLocator ?? DummyInstanceLocator(file: file, line: line)
        self.storeBroadcaster = storeBroadcaster ?? DummyStoreBroadcaster(file: file, line: line)
        self.store = store ?? DummyStore(file: file, line: line)
        
        super.init(file: file, line: line)
    }
    
}
