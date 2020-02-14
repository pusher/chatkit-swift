import TestUtilities
import XCTest
import class PusherPlatform.PPRequestOptions
import struct PusherPlatform.InstanceLocator
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

class ConcreteInstanceWrapperTests: XCTestCase {
    
    let instanceLocator = PusherPlatform.InstanceLocator(string: "version:region:identifier")!
    let sdkInfoProvider = ConcreteSDKInfoProvider(serviceName: "Chatkit", serviceVersion: "v7", sdkInfo: PPSDKInfo.current)
    
    // This test is here for coverage only.  The System Test equivalent tests the true functionality.
    func test_request_regardless_returnsNotNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubTokenProvider = StubTokenProvider(fetchToken_authenticationResultToReturn: .failure(error: "Irrelevant"))
        let dependencies = DependenciesDoubles(instanceLocator: self.instanceLocator,
                                               tokenProvider: stubTokenProvider,
                                               sdkInfoProvider: self.sdkInfoProvider)
        
        let sut = ConcreteInstanceWrapper(dependencies: dependencies)
        
        let requestOptions = PusherPlatform.PPRequestOptions(method: "", path: "")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let generalRequest = sut.request(using: requestOptions,
                                         onSuccess: nil,
                                         onError: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotNil(generalRequest)
    }
    
    // This test is here for coverage only.  The System Test equivalent tests the true functionality.
    func test_subscribeWithResume_regardless_returnsNotNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubTokenProvider = StubTokenProvider(fetchToken_authenticationResultToReturn: .failure(error: "Irrelevant"))
        let dependencies = DependenciesDoubles(instanceLocator: self.instanceLocator,
                                               tokenProvider: stubTokenProvider,
                                               sdkInfoProvider: self.sdkInfoProvider)
        
        let sut = ConcreteInstanceWrapper(dependencies: dependencies)
        
        let requestOptions = PusherPlatform.PPRequestOptions(method: "", path: "")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let resumableSubscription = sut.subscribeWithResume(using: requestOptions,
                                                            onOpening: nil,
                                                            onOpen: nil, onResuming: nil,
                                                            onEvent: nil,
                                                            onEnd: nil,
                                                            onError: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/

        XCTAssertNotNil(resumableSubscription)
    }
    
}
