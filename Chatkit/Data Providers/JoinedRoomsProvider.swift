import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes a collection of all rooms joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsProvider(...)`
///
/// ## What is provided
///
/// The provider exposes a set, `rooms: Set<Room>` which presents the rooms that the current user is a member of.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` changes, implement the `JoinedRoomsProviderDelegate` protocol and assign the `JoinedRoomsProvider.delegate` property.
///
/// Note that when the provider is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the provider
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class JoinedRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the set `rooms` has changed.
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    private let changeController: ChangeController<RoomEntity>
    
    /// The set of all rooms joined by the user.
    public var rooms: Set<Room> {
        let rooms = self.changeController.objects.compactMap { try? $0.snapshot() }
        return Set(rooms)
    }
    
    // MARK: - Initializers
    
    init(currentUser: User, persistenceController: PersistenceController) {
        self.state = .connected
        
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
        
        self.changeController = ChangeController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
        self.changeController.delegate = self
    }
    
}

// MARK: - ChangeControllerDelegate

/// :nodoc:
extension JoinedRoomsProvider: ChangeControllerDelegate {
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didInsertObjects objects: [ResultType], at indexes: IndexSet) where ResultType : NSManagedObject {
        for object in objects {
            guard let object = object as? RoomEntity,
                let room = try? object.snapshot() else {
                    continue
            }
            
            self.delegate?.joinedRoomsProvider(self, didJoinRoom: room)
        }
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? RoomEntity, let room = try? object.snapshot() else {
            return
        }
        
        // TODO: Generate the old value based on the new value and the changeset.
        
        self.delegate?.joinedRoomsProvider(self, didUpdateRoom: room, previousValue: room)
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didMoveObject object: ResultType, from oldIndex: Int, to newIndex: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? RoomEntity, let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomsProvider(self, didLeaveRoom: room)
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `rooms` property of a `JoinedRoomsProvider` has changed.
public protocol JoinedRoomsProviderDelegate: class {
    
    /// Notifies the receiver that the current user has joined a room, and that it has been added to the set.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room joined by the user.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room)
    
    /// Notifies the receiver that a room the current user is a member of has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The new value of the room.
    ///     - previousValue: The value of the room befrore it was updated.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room)
    
    /// Notifies the receiver that the current user has left, or been removed from a room.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room which the user is no longer a member of.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room)
}
