import TestUtilities
import XCTest
@testable import PusherChatkit

import class PusherPlatform.PPRequestOptions
import enum PusherPlatform.HTTPMethod

class StubInstanceTests: XCTestCase {
    
    func test_subscribeAndfireOnEvent_regardless_invokesOnEvent() {
        
        let jsonData = """
        {
            "bob": "fred"
        }
        """.toJsonData()
        
        let stubInstance = StubInstance()
        
        stubInstance.stubSubscribe(result: .success)
        
        let requestOptions = PusherPlatform.PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: "/user")
        
        let expectation: XCTestExpectation.ThreeArgExpectation<String, [String: String], Any>
            = XCTestExpectation.ThreeArgExpectation(functionName: "onEvent")
        
        _ = stubInstance.subscribeWithResume(using: requestOptions,
                                             onOpening: nil,
                                             onOpen: nil,
                                             onResuming: nil,
                                             onEvent: expectation.handler,
                                             onEnd: nil,
                                             onError: nil)
        
        stubInstance.fireOnEvent(jsonData: jsonData)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertExpectationFulfilled(expectation) { (_: String, _: [String: String], jsonDataAsAny: Any) in
            XCTAssertType(jsonDataAsAny) { actualJsonData in
                XCTAssertEqual(actualJsonData, jsonData)
            }
        }
    }
    
}
