import XCTest
import PusherPlatform
import Mockingjay
@testable import PusherChatkit

class TokenProviderTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        MockingjayProtocol.removeAllStubs()
    }

    func testTokenProviderQueuesFetchTokenRequestsIfOneIsUnderway() {
        let tokenEndpoint = "https://testing-chatkit.com/token"
        var callCount = 0

        stub({ $0.url!.absoluteString == tokenEndpoint }, { req in
            let accessToken = callCount > 0 ? "BAD" : "GOOD"
            let tokenObj: [String : Any] = [
                "access_token": accessToken,
                "expires_in": 86400
            ]
            let tokenJSON = try! JSONSerialization.data(withJSONObject: tokenObj, options: [])
            callCount += 1
            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(response, .content(tokenJSON))
        })

        let tokenProvider = PCTokenProvider(url: tokenEndpoint)

        let expOne = expectation(description: "the returned token should be GOOD on first token fetch")
        let expTwo = expectation(description: "the returned token should be GOOD on second token fetch")

        tokenProvider.fetchToken() { res in
            switch res {
            case .success(let token):
                guard token == "GOOD" else {
                    XCTFail("fetched token was not the expected one")
                    return
                }
                expOne.fulfill()
            case .error(_):
                XCTFail("error when fetching token")
            }
        }

        tokenProvider.fetchToken() { res in
            switch res {
            case .success(let token):
                guard token == "GOOD" else {
                    XCTFail("fetched token was not the expected one")
                    return
                }
                expTwo.fulfill()
            case .error(_):
                XCTFail("error when fetching token")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
