import XCTest
@testable import PusherChatkit

class DummyUserService: DummyStoreListener, UserService {
    func fetchUser(withIdentifier identifier: String, handler: @escaping (Result<Void, Error>) -> Void) {
        DummyFail(sender: self, function: #function)
    }
}
