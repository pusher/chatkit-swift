import Foundation
import CoreData
import PusherPlatform

/// A provider which maintains a collection of all rooms joined by the user which have been retrieved from
/// the web service.
public class JoinedRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: RealTimeCollectionState
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    private let fetchedResultsController: FetchedResultsController<RoomEntity>
    private let roomFactory: RoomEntityFactory
    
    /// The array of all rooms joined by the user.
    ///
    /// This array contains all rooms joined by the user and retrieved from the web service as a result
    /// of an internal real time subscription to the web service.
    public var rooms: [Room] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    /// Returns the number of rooms stored locally in the maintained collection of rooms.
    public var numberOfRooms: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(currentUser: User, persistenceController: PersistenceController, completionHandler: @escaping CompletionHandler) {
        self.state = .initializing
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
    
    // MARK: - Methods
    
    /// Returns the room at the given index in the maintained collection of rooms.
    /// - Parameters:
    ///     - index: The index of object that should be returned from the maintained collection of
    ///     rooms.
    ///
    /// - Returns: An instance of `Room` from the maintained collection of rooms or `nil` when
    /// the object could not be found.
    public func room(at index: Int) -> Room? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        guard self.state == .initializing else {
            return
        }
        
        self.state = .online
        
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
        self.delegate?.joinedRoomsProvider(self, didJoinRoomsAtIndexRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomsProvider(self, didUpdateRoomAtIndex: index, previousValue: room)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomsProvider(self, didLeaveRoomAtIndex: index, previousValue: room)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes the methods that will be called by the associated
/// `JoinedRoomsProvider` when the maintainted collection of rooms have changed.
public protocol JoinedRoomsProviderDelegate: class {
    
    /// Notifies the receiver that new rooms have been added to the maintened collection of rooms.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - range: The range of added objects in the maintened collection of rooms.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoomsAtIndexRange range: Range<Int>)
    
    /// Notifies the receiver that a room from the maintened collection of rooms have been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - index: The index of the updated object in the maintened collection of rooms.
    ///     - previousValue: The value of the room prior to the update.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoomAtIndex index: Int, previousValue: Room)
    
    /// Notifies the receiver that a room from the maintened collection of rooms have been removed.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - index: The index of the removed object in the maintened collection of rooms.
    ///     - previousValue: The value of the room prior to the removal.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoomAtIndex index: Int, previousValue: Room)
    
}
