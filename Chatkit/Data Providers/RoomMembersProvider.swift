import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of members for a given room.
///
/// The collection is updated in real time when a user joins or leaves a room.
public class RoomMembersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of members.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of room members changed.
    public weak var delegate: RoomMembersProviderDelegate?
    
    private let roomManagedObjectID: NSManagedObjectID
    private let fetchedResultsController: FetchedResultsController<UserEntity>
    
    /// The set of all room members for the given room.
    public var members: Set<User> {
        let members = self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
        return Set(members)
    }
    
    // MARK: - Initializers
    
    init(room: Room, persistenceController: PersistenceController) {
        self.roomIdentifier = room.identifier
        self.state = .connected
        
        self.roomManagedObjectID = room.objectID
        
        let context = persistenceController.mainContext
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(UserEntity.room), self.roomManagedObjectID)
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

extension RoomMembersProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        for index in range {
            guard index < self.fetchedResultsController.numberOfObjects,
                let entity = self.fetchedResultsController.object(at: index),
                let user = try? entity.snapshot() else {
                    continue
            }
            
            self.delegate?.roomMembersProvider(self, userDidJoin: user)
        }
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? UserEntity, let user = try? object.snapshot() else {
            return
        }
        
        self.delegate?.roomMembersProvider(self, userDidLeave: user)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `RoomMembersProvider` when the maintainted collection of room members have changed.
public protocol RoomMembersProviderDelegate: class {
    
    /// Notifies the receiver that a new member have joined the room.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - user: The user who joined the room.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, userDidJoin user: User)
    
    /// Notifies the receiver that a user from the maintened collection of room members have
    /// left the room.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - user: The user who left the room.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, userDidLeave user: User)
    
}
