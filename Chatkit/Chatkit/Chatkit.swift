import Foundation
import CoreData
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
    
    private let persistenceController: PersistenceController
//    private let networkingController: NetworkingController
    
    private let dataSimulator: DataSimulator
    
    private var usersProviderCache: [UUID : UsersProvider]
    private var availableRoomsProviderCache: [UUID : AvailableRoomsProvider]
    
    // MARK: - Initializers
    
    /// Creates and returns an instance of `Chatkit` entry point.
    ///
    /// - Parameters:
    ///     - instanceLocator: The instance locator used to identify the Chatkit instance.
    ///     - logger: The logger used by the SDK.
    ///
    /// - Returns: An instance of `Chatkit` or throws an error when the initialization failed.
    public init(instanceLocator: String, logger: PPLogger = PPDefaultLogger()) throws {
        self.usersProviderCache = [:]
        self.availableRoomsProviderCache = [:]
        
        self.logger = logger
        
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle.current]) else {
            logger.log("Failed to load Chatkit data model.", logLevel: .error)
            throw PersistenceError.objectModelNotFound
        }
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        self.persistenceController = try PersistenceController(model: model, storeDescriptions: [storeDescription], logger: logger) { error in
            if let error = error {
                logger.log("Failed to load persistent stores with error: \(error.localizedDescription).", logLevel: .error)
            }
        }
        
        self.connectionStatus = .disconnected
        
        let eventParser = ModularEventParser(logger: self.logger)
        eventParser.register(parser: ChatEventParser(persistenceController: self.persistenceController, logger: self.logger), for: .chat, with: .version6)
        
//        self.networkingController = try NetworkingController(instanceLocator: instanceLocator, tokenProvider: tokenProvider, eventParser: eventParser, logger: self.logger)
        
        self.dataSimulator = DataSimulator(persistenceController: self.persistenceController)
    }
    
    // MARK: - Methods
    
    /// Establishes a connection to the Chatkit web service.
    ///
    /// - Parameters:
    ///     - completionHandler: An optional completion handler called when a connection has
    ///     been successfuly established or failed due to an error.
    public func connect(completionHandler: CompletionHandler? = nil) {
        guard self.connectionStatus == .disconnected else {
            return
        }
        
        self.connectionStatus = .connecting
        self.delegate?.chatkit(self, didChangeConnectionStatus: self.connectionStatus)
        
        // Just to be sure that this is being executed on the main thread. It simplifies data simulation.
        DispatchQueue.main.async {
            self.dataSimulator.start { currentUser in
                self.currentUser = currentUser
                self.connectionStatus = .connected
                
                self.delegate?.chatkit(self, didChangeConnectionStatus: self.connectionStatus)
                self.delegate?.chatkit(self, didUpdateCurrentUser: currentUser)
                
                if let completionHandler = completionHandler {
                    completionHandler(nil)
                }
            }
        }
    }
    
    /// Terminates the previously established connection to the Chatkit web service.
    public func disconnect() {
        guard self.connectionStatus == .connected else {
            return
        }
        
        self.connectionStatus = .disconnected
        self.delegate?.chatkit(self, didChangeConnectionStatus: self.connectionStatus)
    }
    
    /// Creates an instance of `UsersProvider`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `UsersProvider` is ready, or an `Error` occurs creating it.
    public func createUsersProvider(completionHandler: @escaping (UsersProvider?, Error?) -> Void) {
        let identifier = UUID()
        self.usersProviderCache[identifier] = UsersProvider { error in
            if let error = error {
                completionHandler(nil, error)
            }
            else if let usersProvider = self.usersProviderCache[identifier] {
                completionHandler(usersProvider, nil)
            }
            
            self.usersProviderCache.removeValue(forKey: identifier)
        }
    }
    
    /// Creates an instance of `AvailableRoomsProvider`.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `AvailableRoomsProvider` is ready, or an `Error` occurs creating it.
    public func createAvailableRoomsProvider(completionHandler: @escaping (AvailableRoomsProvider?, Error?) -> Void) {
        let identifier = UUID()
        self.availableRoomsProviderCache[identifier] = AvailableRoomsProvider { error in
            if let error = error {
                completionHandler(nil, error)
            }
            else if let availableRoomsProvider = self.availableRoomsProviderCache[identifier] {
                completionHandler(availableRoomsProvider, nil)
            }
            
            self.availableRoomsProviderCache.removeValue(forKey: identifier)
        }
    }
    
    /// Creates an instance of `JoinedRoomsProvider`.
    ///
    /// This will provide access to a real time set of `Room`s that the current user is a member of.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `JoinedRoomsProvider` is ready, or an `Error` occurs creating it.
    public func createJoinedRoomsProvider(completionHandler: @escaping (JoinedRoomsProvider?, Error?) -> Void) {
        guard let currentUser = self.currentUser, self.connectionStatus == .connected else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        let provider = JoinedRoomsProvider(currentUser: currentUser, persistenceController: self.persistenceController)
        
        completionHandler(provider, nil)
    }
    
    /// Creates an instance of `MessagesProvider`.
    ///
    /// This will provide access to a real time list of the `Message`s in a given `Room`.
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which the provider will provide messages.
    ///     - completionHandler: A completion handler which will be called when the `MessagesProvider` is ready, or an `Error` occurs creating it.
    public func createMessagesProvider(for room: Room, completionHandler: @escaping (MessagesProvider?, Error?) -> Void) {
        guard self.connectionStatus == .connected else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        let provider = MessagesProvider(room: room, persistenceController: self.persistenceController, dataSimulator: self.dataSimulator)
        
        completionHandler(provider, nil)
    }
    
    /// Creates an instance of `RoomMembersProvider`.
    ///
    /// This will give access to a real time set of the `User`s who are members of a given `Room`
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which the provider will provide member information.
    ///     - completionHandler: A completion handler which will be called when the `RoomMembersProvider` is ready, or an `Error` occurs creating it.
    public func createRoomMembersProvider(for room: Room, completionHandler: @escaping (RoomMembersProvider?, Error?) -> Void) {
        guard self.connectionStatus == .connected else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        let provider = RoomMembersProvider(room: room, persistenceController: self.persistenceController)
        
        completionHandler(provider, nil)
    }
    
    /// Creates an instance of `TypingUsersProvider`.
    ///
    /// This will give access to a real time set of the `User`s who are typing in a given `Room`.
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which this provider will provide information on users who are typing.
    ///     - completionHandler: A completion handler which will be called when the `TypingUsersProvider` is ready, or an `Error` occurs creating it.
    public func createTypingUsersProvider(for room: Room, completionHandler: @escaping (TypingUsersProvider?, Error?) -> Void) {
        guard self.connectionStatus == .connected else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        let provider = TypingUsersProvider(room: room, persistenceController: self.persistenceController)
        
        completionHandler(provider, nil)
    }
    
    /// Creates an instance of `JoinedRoomsViewModel`.
    ///
    /// This will give access to a real time sorted list of the `Room`s that the current user is a member of.
    ///
    /// - Parameters:
    ///     - completionHandler: A completion handler which will be called when the `JoinedRoomsViewModel` is ready, or an `Error` occurs creating it.
    public func createJoinedRoomsViewModel(completionHandler: @escaping (JoinedRoomsViewModel?, Error?) -> Void) {
        self.createJoinedRoomsProvider { provider, error in
            guard error == nil,
                let provider = provider else {
                    completionHandler(nil, error)
                    return
            }
            
            let viewModel = JoinedRoomsViewModel(provider: provider)
            
            completionHandler(viewModel, nil)
        }
    }
    
    /// Creates an instance of `MessagesViewModel`.
    ///
    /// This will give access to a real time list of elements which can be rendered to create a conversation view for a given `Room`.
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which messages should be modelled.
    ///     - completionHandler: A completion handler which will be called when the `MessagesViewModel` is ready, or an `Error` occurs creating it.
    public func createMessagesViewModel(for room: Room, completionHandler: @escaping (MessagesViewModel?, Error?) -> Void) {
        self.createMessagesProvider(for: room) { provider, error in
            guard error == nil,
                let provider = provider else {
                    completionHandler(nil, error)
                    return
            }
            
            let viewModel = MessagesViewModel(provider: provider)
            
            completionHandler(viewModel, nil)
        }
    }
    
    /// Creates an instance of `TypingUsersViewModel`.
    ///
    /// This will give access to a real time `String` describing the users which are currently typing in a given `Room`.
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which typing users should be modelled.
    ///     - userNamePlaceholder: The placeholder used when a user does not have a value set for the `User.name` property.
    ///     - completionHandler: A completion handler which will be called when the `TypingUsersViewModel` is ready, or an `Error` occurs creating it.
    public func createTypingUsersViewModel(for room: Room, userNamePlaceholder: String = "anonymous", completionHandler: @escaping (TypingUsersViewModel?, Error?) -> Void) {
        guard let currentUser = self.currentUser else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        self.createTypingUsersProvider(for: room) { provider, error in
            guard error == nil,
                let provider = provider else {
                    completionHandler(nil, error)
                    return
            }
            
            let viewModel = TypingUsersViewModel(provider: provider, currentUserIdentifier: currentUser.identifier, userNamePlaceholder: userNamePlaceholder)
            
            completionHandler(viewModel, nil)
        }
    }
    
    /// Retrieves a static snapshot of the `User`s who are currently members of the `Room`.
    ///
    /// - Parameters:
    ///     - `room`: The `Room` for which members should be retrieved.
    public func members(for room: Room) -> [User] {
        let roomManagedObjectID = room.objectID
        var members: [User] = []

        let context = persistenceController.mainContext
        context.performAndWait {
            let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(UserEntity.room), roomManagedObjectID)
            let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
                guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                    return .orderedSame
                }

                return NSNumber(value: lhs).compare(NSNumber(value: rhs))
            }

            let memberEntities = context.fetchAll(UserEntity.self, withRelationships: nil, sortedBy: [sortDescriptor], filteredBy: predicate)
            members = memberEntities.compactMap { try? $0.snapshot() }
        }

        return members
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
