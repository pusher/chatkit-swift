import TestUtilities
import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo

class ConcreteSubscriptionFactoryTests: XCTestCase {
    
    func test_makeSubscription_forUser_returnsConcreteSubscriptionWithUserType() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
    
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteSubscriptionFactory(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let subscription = sut.makeSubscription(subscriptionType: subscriptionType)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertType(subscription) { (concreteSubscription: ConcreteSubscription) in
            XCTAssertEqual(concreteSubscription.subscriptionType, subscriptionType)
            XCTAssertTrue(concreteSubscription.delegate === dependencies.subscriptionActionDispatcher)
        }
        
    }
    
    func test_makeSubscription_forRoom_returnsConcreteSubscriptionWithRoomType() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteSubscriptionFactory(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .room(roomIdentifier: "1234")
        let subscription = sut.makeSubscription(subscriptionType: subscriptionType)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertType(subscription) { (concreteSubscription: ConcreteSubscription) in
            XCTAssertEqual(concreteSubscription.subscriptionType, subscriptionType)
            XCTAssertTrue(concreteSubscription.delegate === dependencies.subscriptionActionDispatcher)
        }
        
    }
}
