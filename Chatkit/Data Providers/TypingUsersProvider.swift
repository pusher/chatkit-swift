import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes the set of `User`s currently typing on a given `Room`.
///
/// The collection is updated in real time when a user begins or ends typing on a room.
public class TypingUsersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of typing users.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of typing users changed.
    public weak var delegate: TypingUsersProviderDelegate?
    
    private let roomManagedObjectID: NSManagedObjectID
    private let fetchedResultsController: FetchedResultsController<UserEntity>
    
    /// The set of all users currently typing on a given room.
    public var typingUsers: Set<User> {
        let users = self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
        return Set(users)
    }
    
    // MARK: - Initializers
    
    init(room: Room, persistenceController: PersistenceController) {
        self.roomIdentifier = room.identifier
        self.state = .connected
        
        self.roomManagedObjectID = room.objectID
        
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
    }
    
}

// MARK: - FetchedResultsControllerDelegate

extension TypingUsersProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        for index in range {
            guard index < self.fetchedResultsController.numberOfObjects,
                let entity = self.fetchedResultsController.object(at: index),
                let user = try? entity.snapshot() else {
                    continue
            }
            
            self.delegate?.typingUsersProvider(self, userDidStartTyping: user)
        }
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? UserEntity, let user = try? object.snapshot() else {
            return
        }
        
        self.delegate?.typingUsersProvider(self, userDidStopTyping: user)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `TypingUsersProvider` when the maintainted collection of typing users have changed.
public protocol TypingUsersProviderDelegate: class {
    
    /// Notifies the receiver that a user started typing in the room.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - user: The user who started typing in the room.
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, userDidStartTyping user: User)
    
    /// Notifies the receiver that a user stopped typing in the room.
    ///
    /// - Parameters:
    ///     - typingUsersProvider: The `TypingUsersProvider` that called the method.
    ///     - user: The user who stopped typing in the room.
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, userDidStopTyping user: User)
    
}
