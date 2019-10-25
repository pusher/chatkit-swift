import Foundation

/// A view model which provides a text representations of typing users.
public class TypingUsersViewModel {
    
    // MARK: - Properties
    
    /// The text representations of typing users.
    public private(set) var value: String?
    
    /// The typing users provider used as the source of data.
    public let provider: TypingUsersProvider
    
    /// The placeholder used when a user doeas not have a value set for the name property.
    public let userNamePlaceholder: String
    
    /// The object that is notified when the content of the `value` property has changed.
    public weak var delegate: TypingUsersViewModelDelegate?
    
    // MARK: - Initializers
    
    /// Designated initializer for the class.
    ///
    /// - Parameters:
    ///     - provider: The typing users provider used as the source of data.
    ///     - userNamePlaceholder: The placeholder used when a user doeas not have a value set
    ///     for the name property.
    public init(provider: TypingUsersProvider, userNamePlaceholder: String = "anonymous") {
        self.userNamePlaceholder = userNamePlaceholder
        
        self.provider = provider
        self.provider.delegate = self
        
        self.reload()
    }
    
    // MARK: - Private methods
    
    private func reload() {
        guard self.provider.typingUsers.count > 0 else {
            self.value = nil
            return
        }
        
        let names = self.provider.typingUsers.map { $0.name ?? self.userNamePlaceholder }.sorted().joined(separator: ", ")
        let verb = self.provider.typingUsers.count == 1 ? "is" : "are"
        
        // TODO: Provide localization for all languages supported by Pusher.
        self.value = "\(names) \(verb) typing."
    }
    
}

// MARK: - TypingUsersProviderDelegate

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

/// A delegate protocol that describes methods that will be called by the associated
/// `TypingUsersViewModel` when the content of the `value` property has changed.
public protocol TypingUsersViewModelDelegate: class {
    
    /// Notifies the receiver that the content of the `value` property has changed.
    ///
    /// - Parameters:
    ///     - typingUsersViewModel: The `TypingUsersViewModel` that called the method.
    func typingUsersViewModelDidUpdateValue(_ typingUsersViewModel: TypingUsersViewModel)
    
}
