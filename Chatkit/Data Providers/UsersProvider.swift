import Foundation
import CoreData
import PusherPlatform

public class UsersProvider {
    
    // MARK: - Properties
    
    public private(set) var state: PagedCollectionState
    public private(set) var users: [User]
    
    public weak var delegate: UsersProviderDelegate?
    
    private let userFactory: UserFactory
    
    // MARK: - Accessors
    
    public var numberOfUsers: Int {
        return self.users.count
    }
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .initializing
        self.users = []
        self.userFactory = UserFactory()
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Public methods
    
    public func user(at index: Int) -> User? {
        return index >= 0 && index < self.users.count ? self.users[index] : nil
    }
    
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
        guard self.state == .initializing else {
            return
        }
        
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

public protocol UsersProviderDelegate: class {
    
    func usersProvider(_ usersProvider: UsersProvider, didAddUsersAtIndexRange range: Range<Int>)
    
}
