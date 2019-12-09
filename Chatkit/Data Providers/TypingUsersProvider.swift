import Foundation
import CoreData
import PusherPlatform

/// A provider which exposes the set of `User`s currently typing on a given `Room`.
///
/// Construct an instance of this class using `Chatkit.createTypingUsersProvider(...)`
///
/// ## What is provided
///
/// The provider exposes a set, `typingUsers: Set<User>` which represents the members of a room.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `typingUsers` changes, implement the `TypingUsersProviderDelegate` protocol and assign the `TypingUsersProvider.delegate` property.
///
/// Note that when the provider is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the provider
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class TypingUsersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of typing users.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of typing users changed.
    public weak var delegate: TypingUsersProviderDelegate?
    
    private let roomManagedObjectID: NSManagedObjectID
    private let changeController: ChangeController<UserEntity>
    
    /// The set of all users currently typing on a given room.
    public var typingUsers: Set<User> {
        let users = self.changeController.objects.compactMap { try? $0.snapshot() }
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
        
        self.changeController = ChangeController(sortDescriptors: [sortDescriptor], predicate: predicate, context: context)
        self.changeController.delegate = self
    }
    
}

// MARK: - ChangeControllerDelegate

extension TypingUsersProvider: ChangeControllerDelegate {
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didInsertObjects objects: [ResultType], at indexes: IndexSet) where ResultType : NSManagedObject {
        for object in objects {
            guard let object = object as? UserEntity,
                let user = try? object.snapshot() else {
                    continue
            }
            
            self.delegate?.typingUsersProvider(self, userDidStartTyping: user)
        }
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didMoveObject object: ResultType, from oldIndex: Int, to newIndex: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    public func changeController<ResultType>(_ changeController: ChangeController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
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
