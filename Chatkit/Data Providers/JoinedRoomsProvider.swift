import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of all rooms joined by the user.
///
/// The collection is updated in real time when the user joins or leaves rooms, or the properties of rooms are updated.
public class JoinedRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the provider related to the real time web service.
    ///     - paged: The current state of the provider related to the non-real time web service.
    public private(set) var state: (realTime: RealTimeProviderState, paged: PagedProviderState)
    
    /// The object that is notified when the set `rooms` has changed.
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    private let fetchedResultsController: FetchedResultsController<RoomEntity>
    
    /// The array of all rooms joined by the user.
    public private(set) var rooms: [Room]
    
    // MARK: - Initializers
    
    init(currentUser: User, persistenceController: PersistenceController) {
        self.state.realTime = .connected
        self.state.paged = .fullyPopulated
        
        let context = persistenceController.mainContext
        
        var currentUserID = currentUser.objectID
        context.performAndWait {
            currentUserID = context.object(with: currentUserID).objectID
        }
        
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(RoomEntity.members), currentUserID)
        
        let emptyRoomSortDescriptor = NSSortDescriptor(key: #keyPath(RoomEntity.hasNoMessages), ascending: false)
        let lastMessageDateSortDescriptor = NSSortDescriptor(key: #keyPath(RoomEntity.lastMessage.createdAt), ascending: false)
        let sortDescriptors = [emptyRoomSortDescriptor, lastMessageDateSortDescriptor]
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: sortDescriptors, predicate: predicate, context: context)
        
        self.rooms = self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
        
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - Methods
    
    /// Fetch more rooms from the Chatkit service and add them to the `rooms` array.
    ///
    /// This call is asynchronous because rooms may need to be retrieved from the network.
    ///
    /// On success, the completion handler receives `nil`, and the rooms are added to the `rooms` array.
    ///
    /// The `delegate` will be informed of the change to the `rooms` array.
    ///
    /// - Parameters:
    ///     - completionHandler:An optional completion handler invoked when the operation is complete.
    ///     The completion handler receives an Error, or nil on success.
    public func fetchMoreRooms(completionHandler: CompletionHandler? = nil) {
        guard self.state.paged == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.state.paged = .fetching
        
        // TODO: Fetch more rooms from network/data simulator.
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
            
            self.rooms.insert(room, at: index)
            
            self.delegate?.joinedRoomsProvider(self, didReceiveNewActiveRoom: room, at: index)
        }
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard index < self.rooms.endIndex,
            let object = object as? RoomEntity,
            let room = try? object.snapshot() else {
                return
        }
        
        let previousValue = self.rooms[index]
        
        self.rooms[index] = room
        
        self.delegate?.joinedRoomsProvider(self, didUpdateRoom: room, previousValue: previousValue)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didMoveObject object: ResultType, from oldIndex: Int, to newIndex: Int) where ResultType : NSManagedObject {
        guard oldIndex < self.rooms.endIndex,
            newIndex < self.rooms.endIndex,
            let object = object as? RoomEntity,
            let room = try? object.snapshot() else {
                return
        }
        
        let previousValue = self.rooms[oldIndex]
        
        self.rooms.remove(at: oldIndex)
        self.rooms.insert(room, at: newIndex)
        
        self.delegate?.joinedRoomsProvider(self, didMoveRoom: room, from: oldIndex, to: newIndex, previousValue: previousValue)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? RoomEntity,
            let room = try? object.snapshot() else {
                return
        }
        
        self.rooms.remove(at: index)
        
        self.delegate?.joinedRoomsProvider(self, didRemoveRoom: room)
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `rooms` property of a `JoinedRoomsProvider` has changed.
public protocol JoinedRoomsProviderDelegate: class {
    
    /// Called when more rooms requested with `JoinedRoomsProvider.fetchMoreRooms(...)` have been added to the collection.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - rooms: The array of rooms received from the web service.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didReceiveMoreRooms rooms: [Room])
    
    /// Called when new room have been added to the collection.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The new room received from the web service.
    ///     - index: The index at which the new room has been inserted to the maintained collection of rooms.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didReceiveNewActiveRoom room: Room, at index: Int)
    
    /// Notifies the receiver that a room the current user is a member of has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The new value of the room.
    ///     - previousValue: The value of the room befrore it was updated.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room)
    
    /// Notifies the receiver that a room the current user is a member of has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The new value of the room.
    ///     - oldIndex: The old index of the room before the move.
    ///     - newIndex: The new index of the room after the move.
    ///     - previousValue: The value of the room befrore it was updated.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didMoveRoom room: Room, from oldIndex: Int, to newIndex: Int, previousValue: Room)
    
    /// Called when a room in the collection has been deleted.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room removed from the maintened collection of rooms.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didRemoveRoom room: Room)
}
