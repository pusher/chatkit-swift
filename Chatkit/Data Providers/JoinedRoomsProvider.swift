import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of all rooms joined by the user.
///
/// The collection is updated in real time when the user joins or leaves a room.
public class JoinedRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    private let fetchedResultsController: FetchedResultsController<RoomEntity>
    private let roomFactory: RoomEntityFactory
    
    /// The set of all rooms joined by the user.
    public var rooms: Set<Room> {
        let rooms = self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
        return Set(rooms)
    }
    
    // MARK: - Initializers
    
    init(currentUser: User, persistenceController: PersistenceController, completionHandler: @escaping CompletionHandler) {
        self.state = .degraded
        self.roomFactory = RoomEntityFactory(currentUserManagedObjectID: currentUser.objectID, persistenceController: persistenceController)
        
        let context = persistenceController.mainContext
        
        var currentUserID = currentUser.objectID
        context.performAndWait {
            currentUserID = context.object(with: currentUserID).objectID
        }
        
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(RoomEntity.members), currentUserID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(RoomEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                return .orderedSame
            }
            
            return NSNumber(value: lhs).compare(NSNumber(value: rhs))
        }
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
        self.fetchedResultsController.delegate = self
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        self.state = .connected
        
        self.roomFactory.receiveInitialListOfRooms(numberOfRooms: 10, delay: 1.0) {
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}

// MARK: - FetchedResultsControllerDelegate

extension JoinedRoomsProvider: FetchedResultsControllerDelegate {
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        for index in range {
            guard index < self.fetchedResultsController.numberOfObjects,
                let entity = self.fetchedResultsController.object(at: index),
                let room = try? entity.snapshot() else {
                    continue
            }
            
            self.delegate?.joinedRoomsProvider(self, didJoinRoom: room)
        }
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? RoomEntity, let room = try? object.snapshot() else {
            return
        }
        
        // TODO: Generate the old value based on the new value and the changeset.
        
        self.delegate?.joinedRoomsProvider(self, didUpdateRoom: room, previousValue: room)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? RoomEntity, let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomsProvider(self, didLeaveRoom: room)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `JoinedRoomsProvider` when the maintainted collection of rooms have changed.
public protocol JoinedRoomsProviderDelegate: class {
    
    /// Notifies the receiver that new rooms have been added to the maintened collection of rooms.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room joined by the user.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room)
    
    /// Notifies the receiver that a room from the maintened collection of rooms have been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The updated value of the room.
    ///     - previousValue: The value of the room prior to the update.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room)
    
    /// Notifies the receiver that a room from the maintened collection of rooms have been removed.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room left by the user.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room)
    
}
