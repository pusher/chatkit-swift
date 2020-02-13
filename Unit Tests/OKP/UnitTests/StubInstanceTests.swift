import TestUtilities
import XCTest
@testable import PusherChatkit

import class PusherPlatform.PPRequestOptions
import enum PusherPlatform.HTTPMethod

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
            guard let jsonDict = any as? [String: Any] else {
                XCTFail()
                return
            }
            guard let expectedJson = try? JSONSerialization.jsonObject(with: expectedJsonData, options: []),
                let expectedJsonDict = expectedJson as? [String: Any] else {
                XCTFail()
                return
            }
            XCTAssertEqual(jsonDict.description, expectedJsonDict.description)
        }
        
        _ = stubInstance.subscribeWithResume(using: requestOptions,
                                             onOpening: nil,
                                             onOpen: nil,
                                             onResuming: nil,
                                             onEvent: onEvent,
                                             onEnd: nil,
                                             onError: nil)
        
        stubInstance.fireOnEvent(jsonData: expectedJsonData)
        
        wait(for: [expectation], timeout: 1)
    }
    
}
