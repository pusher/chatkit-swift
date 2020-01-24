import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo
import class PusherPlatform.Instance

class ConcreteInstanceFactoryTests: XCTestCase {
    
    func test_makeInstance_forServiceUser_returnsInstance() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let sdkInfoProvider = ConcreteSDKInfoProvider(locator: DummyInstanceLocator,
                                                      serviceName: "serviceName",
                                                      serviceVersion: "serviceVersion",
                                                      sdkInfo: PPSDKInfo.current)
        let dependencies = DependenciesDoubles(sdkInfoProvider: sdkInfoProvider)
        
        let sut = ConcreteInstanceFactory(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let instance = sut.makeInstance(forType: .service(.user))
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(instance as? PusherPlatform.Instance)
    }
    
}
