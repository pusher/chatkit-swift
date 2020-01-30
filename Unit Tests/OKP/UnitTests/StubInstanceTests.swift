import TestUtilities
import XCTest
@testable import PusherChatkit

import enum PusherPlatform.HTTPMethod
import class PusherPlatform.PPRequestOptions

class StubInstanceTests: XCTestCase {
    
    func test_stuff() {
        
        let expectedJsonData = """
        {
            "bob": "fred"
        }
        """.toJsonData()
        
        let stubInstance = StubInstance()
        
        stubInstance.stubSubscribe(result: .success)
        
        let requestOptions = PusherPlatform.PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: "/user")
        
        let expectation = self.expectation(description: #function)
        
        let onEvent: Instance.OnEvent = { _, _, any in
            expectation.fulfill()
            guard let jsonData = any as? Data else {
                XCTFail()
                return
            }
            XCTAssertEqual(jsonData.toString(), expectedJsonData.toString())
        }
        
        _ = stubInstance.subscribeWithResume(using: requestOptions,
                                             onOpening: nil,
                                             onOpen: nil,
                                             onResuming: nil,
                                             onEvent: onEvent,
                                             onEnd: nil,
                                             onError: nil)
        
        stubInstance.fireSubscriptionEvent(jsonData: expectedJsonData)
        
        waitForExpectations(timeout: 1)
    }
    
}
