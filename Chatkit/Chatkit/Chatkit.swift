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
    
    // MARK: - Types
    
    typealias Dependencies = HasStore & HasTransformer
    
    // MARK: - Properties

    private let dependencies: Dependencies
    
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
    public init(instanceLocator: String, tokenProvider: TokenProvider, logger: PPLogger = PPDefaultLogger()) throws {
        guard let instanceLocator = PusherPlatform.InstanceLocator(string: instanceLocator) else {
            throw NetworkingError.invalidInstanceLocator
        }

        self.logger = logger
        self.connectionStatus = .disconnected
        self.dependencies = ConcreteDependencies(instanceLocator: instanceLocator)
    }
    
    // MARK: - Connecting
    
    /// Establishes a connection to the Chatkit web service.
    ///
    /// - Parameters:
    ///     - completionHandler: An optional completion handler called when a connection has
    ///     been successfuly established or failed due to an error.
    public func connect(completionHandler: CompletionHandler? = nil) {
        // TODO: Implement
        self.connectionStatus = .connected
        if let completionHandler = completionHandler {
            completionHandler(nil)
        }
    }
    
    /// Terminates the previously established connection to the Chatkit web service.
    public func disconnect() {
        // TODO: Implement
        self.connectionStatus = .disconnected
    }
    
    // MARK: - Constructing paged data repositories
    
    /// Creates an instance of `UsersRepository`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `UsersRepository` is ready, or an `Error` occurs creating it.
    public func createUsersRepository(completionHandler: @escaping (UsersRepository?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `AvailableRoomsRepository`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `AvailableRoomsRepository` is ready, or an `Error` occurs creating it.
    public func createAvailableRoomsRepository(completionHandler: @escaping (AvailableRoomsRepository?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    // MARK: - Constructing real time data repositories
    
    /// Creates an instance of `JoinedRoomsRepository`.
    ///
    /// This will provide access to a real time set of `Room`s that the current user is a member of.
    public func createJoinedRoomsRepository() -> JoinedRoomsRepository {
        let filter = JoinedRoomsRepository.Filter()
        let buffer = ConcreteBuffer(filter: filter, dependencies: self.dependencies)
        
        return JoinedRoomsRepository(buffer: buffer, dependencies: self.dependencies)
    }
    
    /// Creates an instance of `MessagesRepository`.
    ///
    /// This will provide access to a real time list of the `Message`s in a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which the repository will provide messages.
    ///     - completionHandler: A completion handler which will be called when the `MessagesRepository` is ready, or an `Error` occurs creating it.
    public func createMessagesRepository(for room: Room, completionHandler: @escaping (MessagesRepository?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `RoomMembersRepository`.
    ///
    /// This will give access to a real time set of the `User`s who are members of a given `Room`
    ///
    /// - Parameters:
    ///     - room: The `Room` for which the repository will provide member information.
    ///     - completionHandler: A completion handler which will be called when the `RoomMembersRepository` is ready, or an `Error` occurs creating it.
    public func createRoomMembersRepository(for room: Room, completionHandler: @escaping (RoomMembersRepository?, Error?) -> Void) {
        // TODO: Implement
        completionHandler(nil, nil)
    }
    
    /// Creates an instance of `TypingUsersRepository`.
    ///
    /// This will give access to a real time set of the `User`s who are typing in a given `Room`.
    ///
    /// - Parameters:
    ///     - room: The `Room` for which this repository will provide information on users who are typing.
    ///     - completionHandler: A completion handler which will be called when the `TypingUsersRepository` is ready, or an `Error` occurs creating it.
    public func createTypingUsersRepository(for room: Room, completionHandler: @escaping (TypingUsersRepository?, Error?) -> Void) {
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
