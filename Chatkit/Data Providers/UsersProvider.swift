import Foundation
import CoreData
import PusherPlatform

/// A provider which maintains a collection of users retrieved from the web service.
public class UsersProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: PagedProviderState
    
    /// The array of all users stored locally.
    ///
    /// This array contains all users retrieved from the web service as a result of an implicit initial call made
    /// to the web service during the initialization of the class as well as all explicit calls triggered
    /// as a result of calling `fetchMoreUsers(numberOfUsers:completionHandler:)` method.
    public private(set) var users: [User]
    
    /// The object that is notified when the content of the maintained collection of users changed.
    public weak var delegate: UsersProviderDelegate?
    
    private let userFactory: UserFactory
    
    /// Returns the number of users stored locally in the maintained collection of users.
    public var numberOfUsers: Int {
        return self.users.count
    }
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .partiallyPopulated
        self.users = []
        self.userFactory = UserFactory()
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
    /// Returns the user at the given index in the maintained collection of users.
    /// - Parameters:
    ///     - index: The index of object that should be returned from the maintained collection of
    ///     users.
    ///
    /// - Returns: An instance of `User` from the maintained collection of users or `nil` when
    /// the object could not be found.
    public func user(at index: Int) -> User? {
        return index >= 0 && index < self.users.count ? self.users[index] : nil
    }
    
    /// Triggers an asynchronous call to the web service that extends the maintained collection of users
    /// by the given maximum number of entries.
    ///
    /// - Parameters:
    ///     - numberOfUsers: The maximum number of users that should be retrieved from the web
    ///     service.
    ///     - completionHandler:An optional completion handler called when the call to the web
    ///     service finishes with either a successful result or an error.
    public func fetchMoreUsers(numberOfUsers: UInt, completionHandler: CompletionHandler? = nil) {
        guard self.state == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.state = .fetching
        
        let lastUserIdentifier = self.users.last?.identifier ?? "-1"
        
        self.userFactory.receiveUsers(numberOfUsers: Int(numberOfUsers), lastUserIdentifier: lastUserIdentifier, delay: 1.0) { users in
            let range = Range<Int>(uncheckedBounds: (lower: self.users.count, upper: self.users.count + users.count))
            
            self.users.append(contentsOf: users)
            
            self.state = .partiallyPopulated
            
            self.delegate?.usersProvider(self, didAddUsersAtIndexRange: range)
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        self.state = .fetching
        
        self.userFactory.receiveUsers(numberOfUsers: 5, lastUserIdentifier: "-1", delay: 1.0) { users in
            self.users.append(contentsOf: users)
            
            self.state = .partiallyPopulated
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated `UsersProvider`
/// when the maintainted collection of users have changed.
public protocol UsersProviderDelegate: class {
    
    /// Notifies the receiver that new users have been added to the maintened collection of users.
    ///
    /// - Parameters:
    ///     - usersProvider: The `UsersProvider` that called the method.
    ///     - range: The range of added objects in the maintened collection of users.
    func usersProvider(_ usersProvider: UsersProvider, didAddUsersAtIndexRange range: Range<Int>)
    
}
