import Foundation
import CoreData
import PusherPlatform

/// A provider which maintains a collection of users retrieved from the web service.
public class UsersProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: PagedProviderState
    
    /// The set of all users stored locally.
    ///
    /// This array contains all users retrieved from the web service as a result of an implicit initial call made
    /// to the web service during the initialization of the class as well as all explicit calls triggered
    /// as a result of calling `fetchMoreUsers(numberOfUsers:completionHandler:)` method.
    public private(set) var users: Set<User>
    
    /// The object that is notified when the content of the maintained collection of users changed.
    public weak var delegate: UsersProviderDelegate?
    
    private var lastIdentifier: String
    private let userFactory: UserFactory
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .partiallyPopulated
        self.users = []
        self.lastIdentifier = "-1"
        self.userFactory = UserFactory()
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
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
        
        self.userFactory.receiveUsers(numberOfUsers: Int(numberOfUsers), lastUserIdentifier: self.lastIdentifier, delay: 1.0) { users in
            guard let lastIdentifier = users.last?.identifier else {
                if let completionHandler = completionHandler {
                    completionHandler(nil)
                }
                
                return
            }
            
            self.lastIdentifier = lastIdentifier
            self.users.formUnion(users)
            
            self.state = .partiallyPopulated
            
            self.delegate?.usersProvider(self, didReceiveUsers: Set(users))
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        self.state = .fetching
        
        self.userFactory.receiveUsers(numberOfUsers: 5, lastUserIdentifier: self.lastIdentifier, delay: 1.0) { users in
            guard let lastIdentifier = users.last?.identifier else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            self.lastIdentifier = lastIdentifier
            self.users.formUnion(users)
            
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
    ///     - users: The set of users added to the maintened collection of users.
    func usersProvider(_ usersProvider: UsersProvider, didReceiveUsers users: Set<User>)
    
}
