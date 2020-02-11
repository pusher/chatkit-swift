import XCTest
import enum PusherPlatform.AuthenticationResult
import protocol PusherPlatform.Token
import protocol PusherPlatform.TokenProvider
@testable import PusherChatkit

// MARK: - TokenProvider

public class DummyTokenProvider: DummyBase, TokenProvider {

    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
        DummyFail(sender: self, function: #function)
        completionHandler(.failure(error: "Unexpected call `\(#function)` on `\(String(describing: self))`."))
    }
}

public class StubTokenProvider: DoubleBase, TokenProvider {
    
    private var fetchToken_authenticationResultToReturn: AuthenticationResult? = nil
    public private(set) var fetchToken_actualCountCount: UInt = 0
    
    public init(fetchToken_authenticationResultToReturn: AuthenticationResult,
         file: StaticString = #file, line: UInt = #line) {
        
        self.fetchToken_authenticationResultToReturn = fetchToken_authenticationResultToReturn
        
        super.init(file: file, line: line)
    }
    
    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
        fetchToken_actualCountCount += 1
        guard let fetchToken_authenticationResultToReturn = fetchToken_authenticationResultToReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return
        }
        completionHandler(fetchToken_authenticationResultToReturn)
    }
}

//// MARK: - Token
//
//public class DummyToken: DummyBase, Token {
//    
//    public var value: String  {
//        DummyFail(sender: self, function: #function)
//        return ""
//    }
//    
//    public var expiryDate: Date {
//        DummyFail(sender: self, function: #function)
//        return Date()
//    }
//}
