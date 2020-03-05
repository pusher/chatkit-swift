import TestUtilities
import XCTest
import class PusherPlatform.Instance
import struct PusherPlatform.InstanceLocator
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

class ConcreteInstanceWrapperFactoryTests: XCTestCase {
    
    let instanceLocator = InstanceLocator(string: "version:region:identifier")!
    
    func test_makeInstanceWrapper_forUserSubscription_returnsConcreteInstanceWrapper() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let instanceLocator = self.instanceLocator
        let sdkInfoProvider = ConcreteSDKInfoProvider(serviceName: "serviceName",
                                                      serviceVersion: "serviceVersion",
                                                      sdkInfo: PPSDKInfo.current)
        let dependencies = DependenciesDoubles(instanceLocator: instanceLocator,
                                               sdkInfoProvider: sdkInfoProvider)
        
        let sut = ConcreteInstanceWrapperFactory(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let instanceWrapper = sut.makeInstanceWrapper(forType: .subscription(.user))
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(instanceWrapper is ConcreteInstanceWrapper)
    }
    
}
