import TestUtilities
import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo

class ConcreteSubscriptionFactoryTests: XCTestCase {
    
    func test_makeSubscription_forServiceUser_returnsInstance() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
    
        let sut = ConcreteSubscriptionFactory(dependencies: DependenciesDoubles())
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let subscription = sut.makeSubscription()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(subscription as? ConcreteSubscription)
    }
    
}
