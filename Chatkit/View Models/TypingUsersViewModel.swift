import Foundation

/// A view model which provides a textual representation of the `User`s currently typing in a `Room`.
///
/// Construct an instance of this class using `Chatkit.createTypingUsersViewModel(...)`
///
/// This class is intended to be bound to a text UI component.
///
/// This class exposes a `String?`, and accepts a delegate which will be called whenever the value has changed.
///
/// The full set of users who are typing is:
/// - filtered to exclude the current user
/// - sorted by name
/// - limited to 3 entries with a "<X> more" placeholder if more than 3 users are typing
/// - rendered using the `User.name` property, or a configurable placeholder name if this field is not set.
public class TypingUsersViewModel {
    
    // MARK: - Properties
    
    private let provider: TypingUsersProvider
    private let currentUserIdentifier: String
    private let userNamePlaceholder: String
    
    /// The textual description of the set of currently typing users, or `nil` of no users are typing.
    public private(set) var value: String?
    
    /// The current state of the provider used by the view model as the data source.
    public var state: RealTimeProviderState {
        return self.provider.state
    }

    /// The object that is notified when the content of the `value` property has changed.
    public weak var delegate: TypingUsersViewModelDelegate?
    
    // MARK: - Initializers
    
    init(provider: TypingUsersProvider, currentUserIdentifier: String, userNamePlaceholder: String) {
        self.currentUserIdentifier = currentUserIdentifier
        self.userNamePlaceholder = userNamePlaceholder
        
        self.provider = provider
        self.provider.delegate = self
        
        self.reload()
    }
    
    // MARK: - Private methods
    
    private func reload() {
        var sortedNames = self.provider.typingUsers.filter{ $0.identifier != self.currentUserIdentifier }.map { $0.name ?? self.userNamePlaceholder }.sorted()
        
        guard sortedNames.count > 0 else {
            self.value = nil
            return
        }
        
        if sortedNames.count > 3 {
            let numberOfTruncatedUsers = sortedNames.count - 3
            
            sortedNames = Array(sortedNames.prefix(3))
            sortedNames.append("\(numberOfTruncatedUsers) more")
        }
        
        let names = sortedNames.joined(separator: ", ")
        let verb = self.provider.typingUsers.count == 1 ? "is" : "are"
        
        // TODO: Provide localization for all languages supported by Pusher.
        self.value = "\(names) \(verb) typing."
    }
    
}

// MARK: - TypingUsersProviderDelegate

/// :nodoc:
extension TypingUsersViewModel: TypingUsersProviderDelegate {
    
    public func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, userDidStartTyping user: User) {
        self.reload()
        self.delegate?.typingUsersViewModelDidUpdateValue(self)
    }
    
    public func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, userDidStopTyping user: User) {
        self.reload()
        self.delegate?.typingUsersViewModelDidUpdateValue(self)
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `value` of a `TypingUsersViewModel` has changed.
public protocol TypingUsersViewModelDelegate: class {
    
    /// Called when the content of the `value` property has changed.
    ///
    /// - Parameters:
    ///     - typingUsersViewModel: The `TypingUsersViewModel` that called the method.
    func typingUsersViewModelDidUpdateValue(_ typingUsersViewModel: TypingUsersViewModel)
    
}
