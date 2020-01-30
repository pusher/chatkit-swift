import XCTest
@testable import PusherChatkit

public class DummyUserService: DummyStoreListener, UserService {
    
    public func fetchUser(withIdentifier identifier: String, handler: @escaping (Result<Void, Error>) -> Void) {
        DummyFail(sender: self, function: #function)
    }
}
