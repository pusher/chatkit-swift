import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of users currently typing on a given room.
///
/// The collection is updated in real time when a user begins or ends typing on a room.
public class TypingUsersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of typing users.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of typing users changed.
    public weak var delegate: TypingUsersProviderDelegate? {
        didSet {
            if delegate == nil {
                self.typingUsersFactory.stopTyping()
            }
            else {
                self.typingUsersFactory.startTyping()
            }
        }
    }
    
    private let roomManagedObjectID: NSManagedObjectID
    private let fetchedResultsController: FetchedResultsController<UserEntity>
    private let typingUsersFactory: TypingUsersFactory
    
    /// The array of all users currently typing on a given room.
    public var typingUsers: [User] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    /// Returns the number of users stored locally in the maintained collection of typing users.
    public var numberOfTypingUsers: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(room: Room, currentUser: User, persistenceController: PersistenceController, completionHandler: @escaping CompletionHandler) {
        self.roomIdentifier = room.identifier
        self.state = .degraded
        
        self.roomManagedObjectID = room.objectID
        self.typingUsersFactory = TypingUsersFactory(roomID: self.roomManagedObjectID, persistenceController: persistenceController)
        
        let context = persistenceController.mainContext
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(UserEntity.typingInRooms), self.roomManagedObjectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                return .orderedSame
            }
            
            return NSNumber(value: lhs).compare(NSNumber(value: rhs))
        }
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
        self.fetchedResultsController.delegate = self
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
    /// Returns the users at the given index in the maintained collection of typing users.
    ///
    /// - Parameters:
    ///     - index: The index of object that should be returned from the maintained collection of
    ///     typing users.
    ///
    /// - Returns: An instance of `User` from the maintained collection of typing users or `nil`
    /// when the object could not be found.
    public func typingUser(at index: Int) -> User? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        self.state = .connected
        
        DispatchQueue.main.async {
            completionHandler(nil)
        }
    }
    
}

// MARK: - FetchedResultsControllerDelegate

extension TypingUsersProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        self.delegate?.typingUsersProvider(self, didAddTypingUsersAtIndexRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? UserEntity, let member = try? object.snapshot() else {
            return
        }
        
        self.delegate?.typingUsersProvider(self, didRemoveTypingUserAtIndex: index, previousValue: member)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `TypingUsersProvider` when the maintainted collection of typing users have changed.
public protocol TypingUsersProviderDelegate: class {
    
    /// Notifies the receiver that new members have been added to the maintened collection of room
    /// members.
    ///
    /// - Parameters:
    ///     - typingUsersProvider: The `TypingUsersProvider` that called the method.
    ///     - range: The range of added objects in the maintened collection of typing users.
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, didAddTypingUsersAtIndexRange range: Range<Int>)
    
    /// Notifies the receiver that a room member from the maintened collection of room members have
    /// been removed.
    ///
    /// - Parameters:
    ///     - typingUsersProvider: The `TypingUsersProvider` that called the method.
    ///     - index: The index of the removed object in the maintened collection of typing users.
    ///     - previousValue: The value of the users prior to the removal.
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, didRemoveTypingUserAtIndex index: Int, previousValue: User)
    
}
