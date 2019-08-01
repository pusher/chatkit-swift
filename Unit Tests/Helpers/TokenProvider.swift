import Foundation
import PusherPlatform

public class TestTokenProvider: PPTokenProvider {
    
    //MARK: - PPTokenProvider
    
    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        completionHandler(.success(token: "testToken"))
    }
    
}
