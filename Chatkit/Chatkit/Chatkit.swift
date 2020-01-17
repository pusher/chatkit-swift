import Foundation
import PusherPlatform

/// This class is the entry point to the SDK.
///
/// An instance of this class will maintain a real time connection to the
/// Chatkit service, allow access to the retrieved data, and provide methods
/// to manipulate that data in the context of the current user.
///
/// See [Initialization](initialization.html) for details on how to get it up
/// and running.
public class Chatkit {
    
    // MARK: - Properties
    
    /// Returns the users who is currently logged in to the web service.
    /// - Returns: An instance of `User` when a connection to Chatkit web service has been
    /// established or `nil` when offline.
    public private(set) var currentUser: User?
    
    /// The current status of the connection to Chatkit web service.
    public private(set) var connectionStatus: ConnectionStatus
    
    /// The logger used by the SDK.
    public let logger: PPLogger
    
    /// The object that is notified when the status of the connection to Chatkit web service changed.
    public weak var delegate: ChatkitDelegate?
    
    private let networkingController: NetworkingController
    
    private let dependencies: Dependencies
    
    // MARK: - Initializers
    
    /// Creates and returns an instance of `Chatkit` entry point.
    ///
    /// - Parameters:
    ///     - instanceLocator: The instance locator used to identify the Chatkit instance.
    ///     This is found in the Chatkit dashboard.
    ///     - tokenProvider: An object which will be used to fetch authentication token for the
    ///     user. See `ChatkitTokenProviders`
    ///     - logger: The logger used by the SDK.
    ///
    /// - Returns: An instance of `Chatkit` or throws an error when the initialization failed.
    public convenience init(instanceLocator: String, tokenProvider: TokenProvider, logger: PPLogger = PPDefaultLogger()) throws {
        let dependencies = ConcreteDependencies(instanceLocator: instanceLocator)
        try self.init(instanceLocator: instanceLocator, tokenProvider: tokenProvider, logger: logger, dependencies: dependencies)
    }
    
    internal init(instanceLocator: String, tokenProvider: TokenProvider, logger: PPLogger = PPDefaultLogger(), dependencies: Dependencies) throws {
        self.logger = logger
        self.connectionStatus = .disconnected
        
        self.networkingController = try NetworkingController(instanceLocator: instanceLocator, tokenProvider: tokenProvider, logger: self.logger)
        
        self.dependencies = ConcreteDependencies(instanceLocator: instanceLocator)
    }
    
    // MARK: - Connecting
    
    /// Establishes a connection to the Chatkit web service.
    ///
    /// - Parameters:
    ///     - completionHandler: An optional completion handler called when a connection has
    ///     been successfuly established or failed due to an error.
    public func connect(completionHandler: CompletionHandler? = nil) {
        
        // TODO: Implement properly
        
        dependencies.subscriptionManager.subscribe(.session) { result in
            switch result {
            case .success:
                self.connectionStatus = .connected
                completionHandler?(nil)
            case let .failure(error):
                self.connectionStatus = .disconnected
                completionHandler?(error)
            }
        }
        
    }
    
    /// Terminates the previously established connection to the Chatkit web service.
    public func disconnect() {
        // TODO: Implement
        self.connectionStatus = .disconnected
    }
    
    // MARK: - Constructing paged data providers
    
    /// Creates an instance of `UsersProvider`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `UsersProvider` is ready, or an `Error` occurs creating it.
    public func createUsersProvider(completionHandler: @escaping (UsersProvider?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `AvailableRoomsProvider`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `AvailableRoomsProvider` is ready, or an `Error` occurs creating it.
    public func createAvailableRoomsProvider(completionHandler: @escaping (AvailableRoomsProvider?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    // MARK: - Constructing real time data providers
    
    /// Creates an instance of `JoinedRoomsProvider`.
    ///
    /// This will provide access to a real time set of `Room`s that the current user is a member of.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `JoinedRoomsProvider` is ready, or an `Error` occurs creating it.
    public func createJoinedRoomsProvider(completionHandler: @escaping (JoinedRoomsProvider?, Error?) -> Void) {
        // TODO: Implement
        let currentUser = User(identifier: "identifier",
                               name: "name",
                               avatar: nil,
                               presenceState: .online,
                               customData: nil,
                               createdAt: Date(),
                               updatedAt: Date())
        let provider = JoinedRoomsProvider(currentUser: currentUser)
        completionHandler(provider, nil)
    }
    
    /// Creates an instance of `MessagesProvider`.
    ///
    /// This will provide access to a real time list of the `Message`s in a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which the provider will provide messages.
    ///     - completionHandler: A completion handler which will be called when the `MessagesProvider` is ready, or an `Error` occurs creating it.
    public func createMessagesProvider(for room: Room, completionHandler: @escaping (MessagesProvider?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `RoomMembersProvider`.
    ///
    /// This will give access to a real time set of the `User`s who are members of a given `Room`
    ///
    /// - Parameters:
    ///     - room: The `Room` for which the provider will provide member information.
    ///     - completionHandler: A completion handler which will be called when the `RoomMembersProvider` is ready, or an `Error` occurs creating it.
    public func createRoomMembersProvider(for room: Room, completionHandler: @escaping (RoomMembersProvider?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `TypingUsersProvider`.
    ///
    /// This will give access to a real time set of the `User`s who are typing in a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which this provider will provide information on users who are typing.
    ///     - completionHandler: A completion handler which will be called when the `TypingUsersProvider` is ready, or an `Error` occurs creating it.
    public func createTypingUsersProvider(for room: Room, completionHandler: @escaping (TypingUsersProvider?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    // MARK: - Constructing real time view models
    
    /// Creates an instance of `JoinedRoomsViewModel`.
    ///
    /// This will give access to a real time sorted list of the `Room`s that the current user is a member of.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `JoinedRoomsViewModel` is ready, or an `Error` occurs creating it.
    public func createJoinedRoomsViewModel(completionHandler: @escaping (JoinedRoomsViewModel?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `MessagesViewModel`.
    ///
    /// This will give access to a real time list of elements which can be rendered to create a conversation view for a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which messages should be modelled.
    ///     - completionHandler: A completion handler which will be called when the `MessagesViewModel` is ready, or an `Error` occurs creating it.
    public func createMessagesViewModel(for room: Room, completionHandler: @escaping (MessagesViewModel?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `TypingUsersViewModel`.
    ///
    /// This will give access to a real time `String` describing the users which are currently typing in a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which typing users should be modelled.
    ///     - userNamePlaceholder: The placeholder used when a user does not have a value set for the `User.name` property.
    ///     - completionHandler: A completion handler which will be called when the `TypingUsersViewModel` is ready, or an `Error` occurs creating it.
    public func createTypingUsersViewModel(for room: Room, userNamePlaceholder: String = "anonymous", completionHandler: @escaping (TypingUsersViewModel?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    // MARK: - Retrieving static snapshots of chat data
    
    /// Retrieves a static snapshot of the `User`s who are currently members of the `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which members should be retrieved.
    ///     - includeCurrentUser: Whether the return value should include an entry for the current user.
    public func members(for room: Room, includeCurrentUser: Bool = false) -> [User] {
        // TODO: Implement
        return []
    }
}

// MARK: - Delegate

/// A delegate protocol for observing changes to the `Chatkit` handle, including the properties of
/// the currently logged in user, and the state of the connection to the Chatkit services.
public protocol ChatkitDelegate: class {
    
    /// Called when the properties of the currently authenticated user of the SDK change.
    ///
    /// - Parameters:
    ///     - chatkit: The `Chatkit` class that called the method.
    ///     - currentUser: The new `User` entity representing the currently logged in user.
    func chatkit(_ chatkit: Chatkit, didUpdateCurrentUser currentUser: User)
    
    /// Called when the state of the connection to the Chatkit service changes.
    ///
    /// - Parameters:
    ///     - chatkit: The `Chatkit` class that called the method.
    ///     - connectionStatus: The new state of the connection to the Chatkit service.
    func chatkit(_ chatkit: Chatkit, didChangeConnectionStatus connectionStatus: ConnectionStatus)
    
}
