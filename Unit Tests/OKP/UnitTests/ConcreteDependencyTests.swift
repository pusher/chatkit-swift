import XCTest
@testable import PusherChatkit


class ConcreteDependencyTests: XCTestCase {
    
    func test_stuff() {
        
        let dependencies = ConcreteDependencies(instanceLocator: "dummy:instance:locator")
        
        let subscriptionManager = dependencies.subscriptionManager
        
        print(subscriptionManager)
    }
    
}
