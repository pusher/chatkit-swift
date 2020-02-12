import TestUtilities
import XCTest
import class PusherPlatform.Instance
import struct PusherPlatform.InstanceLocator
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

class ConcreteInstanceFactoryTests: XCTestCase {
    
    let instanceLocator = PusherPlatform.InstanceLocator(string: "version:region:identifier")!
    
    func test_makeInstance_forUserSubscription_returnsConcreteInstance() {
        
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
        
        let instance = sut.makeInstance(forType: .subscription(.user))
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(instance is ConcreteInstance)
    }
    
}
