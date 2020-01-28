import XCTest
@testable import PusherChatkit

import enum PusherPlatform.AuthenticationResult
import protocol PusherPlatform.Token
import protocol PusherPlatform.TokenProvider

class DummyTokenProvider: DummyBase, TokenProvider {

    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
        DummyFail(sender: self, function: #function)
        completionHandler(.failure(error: "Unexpected call `\(#function)` on `\(String(describing: self))`."))
    }
}
