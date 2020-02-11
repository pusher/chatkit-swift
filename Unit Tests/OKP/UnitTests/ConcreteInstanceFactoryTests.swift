import TestUtilities
import XCTest
import class PusherPlatform.Instance
import struct PusherPlatform.InstanceLocator
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

class ConcreteInstanceFactoryTests: XCTestCase {
    
    let instanceLocator = PusherPlatform.InstanceLocator(string: "version:region:identifier")!
    
    func test_makeInstance_forServiceUser_returnsInstance() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = self.instanceLocator
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
        
        XCTAssertTrue(instance is ConcreteInstance)
    }
    
}
