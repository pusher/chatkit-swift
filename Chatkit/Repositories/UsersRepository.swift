import Foundation

/// A repository which maintains a collection of users retrieved from the web service.
public class UsersRepository {
    
    // MARK: - Properties
    
    /// The current state of the repository.
    public private(set) var state: PagedRepositoryState
    
    /// The set of all users stored locally.
    ///
    /// This array contains all users retrieved from the web service as a result of an implicit initial call made
    /// to the web service during the initialization of the class as well as all explicit calls triggered
    /// as a result of calling `fetchMoreUsers(numberOfUsers:completionHandler:)` method.
    public private(set) var users: Set<User>
    
    /// The object that is notified when the content of the maintained collection of users changed.
    public weak var delegate: UsersRepositoryDelegate?
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .partiallyPopulated
        self.users = []
        
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
        
        // TODO: Implement
        if let completionHandler = completionHandler {
            completionHandler(nil)
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        // TODO: Implement
        completionHandler(nil)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated `UsersRepository`
/// when the maintainted collection of users have changed.
public protocol UsersRepositoryDelegate: class {
    
    /// Notifies the receiver that new users have been added to the maintened collection of users.
    ///
    /// - Parameters:
    ///     - usersRepository: The `UsersRepository` that called the method.
    ///     - users: The set of users added to the maintened collection of users.
    func usersRepository(_ usersRepository: UsersRepository, didReceiveUsers users: Set<User>)
    
}
