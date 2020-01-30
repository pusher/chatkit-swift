import TestUtilities
import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo
import class PusherPlatform.Instance

class ConcreteInstanceFactoryTests: XCTestCase {
    
    // TODO:
    
    func test_makeInstance_forServiceUser_returnsInstance() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = StubInstanceLocator(string: "valid:instance:locator")
        let sdkInfoProvider = ConcreteSDKInfoProvider(serviceName: "serviceName",
                                                      serviceVersion: "serviceVersion",
                                                      sdkInfo: PPSDKInfo.current)
        let dependencies = DependenciesDoubles(instanceLocator: instanceLocator,
                                               sdkInfoProvider: sdkInfoProvider)
        
        let sut = ConcreteInstanceFactory(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let instance = sut.makeInstance(forType: .service(.user))
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(instance as? PusherPlatform.Instance)
        XCTAssertEqual(instanceLocator.region_actualCallCount, 1)
        XCTAssertEqual(instanceLocator.identifier_actualCallCount, 1)
        XCTAssertEqual(instanceLocator.version_actualCallCount, 1)
    }
    
}
