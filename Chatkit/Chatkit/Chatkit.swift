import Foundation
import CoreData
import PusherPlatform

/// This class represents an entry point to Chatkit SDK allowing to establish a connection to the web service
/// and retrieve data from it.
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
    ///     - completionHandler: A completion handler called when an instance of
    ///     `UsersProvider` has been successfuly created or the instantiation failed due to an error.
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
    ///     - completionHandler: A completion handler called when an instance of
    ///     `AvailableRoomsProvider` has been successfuly created or the instantiation failed
    ///     due to an error.
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
    /// - Parameters:
    ///     - completionHandler: A completion handler called when an instance of
    ///     `JoinedRoomsProvider` has been successfuly created or the instantiation failed due to
    ///     an error.
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
    /// - Parameters:
    ///     - completionHandler: A completion handler called when an instance of
    ///     `MessagesProvider` has been successfuly created or the instantiation failed due to
    ///     an error.
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
    /// - Parameters:
    ///     - completionHandler: A completion handler called when an instance of
    ///     `RoomMembersProvider` has been successfuly created or the instantiation failed due to
    ///     an error.
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
    /// - Parameters:
    ///     - completionHandler: A completion handler called when an instance of
    ///     `TypingUsersProvider` has been successfuly created or the instantiation failed due to
    ///     an error.
    public func createTypingUsersProvider(for room: Room, completionHandler: @escaping (TypingUsersProvider?, Error?) -> Void) {
        guard self.connectionStatus == .connected else {
            completionHandler(nil, NetworkingError.disconnected)
            return
        }
        
        let provider = TypingUsersProvider(room: room, persistenceController: self.persistenceController)
        
        completionHandler(provider, nil)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `Chatkit` class when the status of the maintained connection to Chatkit web service have changed.
public protocol ChatkitDelegate: class {
    
    /// Notifies the receiver that the currently logged in user have changed.
    ///
    /// - Parameters:
    ///     - chatkit: The `Chatkit` class that called the method.
    ///     - currentUser: The new current user have established the connection to Chatkit web
    ///     service.
    func chatkit(_ chatkit: Chatkit, didUpdateCurrentUser currentUser: User)
    
    /// Notifies the receiver that the status of the maintained connection to Chatkit web service have
    /// changed.
    ///
    /// - Parameters:
    ///     - chatkit: The `Chatkit` class that called the method.
    ///     - currentUser: The new status of the connection to the web service.
    func chatkit(_ chatkit: Chatkit, didChangeConnectionStatus connectionStatus: ConnectionStatus)
    
}
