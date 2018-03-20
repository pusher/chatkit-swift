import XCTest
import PusherPlatform
import OHHTTPStubs
@testable import PusherChatkit

class TokenProviderTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testTokenProviderQueuesFetchTokenRequestsIfOneIsUnderway() {
        let tokenEndpoint = "https://testing-chatkit.com/token"
        var callCount = 0

        stub(condition: isAbsoluteURLString(tokenEndpoint)) { _ in
            let accessToken = callCount > 0 ? "BAD" : "GOOD"
            let tokenObj: [String : Any] = [
                "access_token": accessToken,
                "refresh_token": "wedontcareaboutthis",
                "expires_in": 86400
            ]
            callCount += 1
            return OHHTTPStubsResponse(jsonObject: tokenObj, statusCode: 200, headers: nil).requestTime(0.1, responseTime: 0.1)
        }

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
