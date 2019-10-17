import Foundation
import CoreData
import PusherPlatform

/// A provider which maintains a collection of members of a given room which have been retrieved from
/// the web service.
public class RoomMembersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of members.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of room members changed.
    public weak var delegate: RoomMembersProviderDelegate? {
        didSet {
            if delegate == nil {
                self.userFactory.stopAddingNewMembers()
                self.userFactory.stopRemovingMembers()
            }
            else {
                self.userFactory.startAddingNewMembers()
                self.userFactory.startRemovingMembers()
            }
        }
    }
    
    private let roomManagedObjectID: NSManagedObjectID
    private let fetchedResultsController: FetchedResultsController<UserEntity>
    private let userFactory: UserEntityFactory
    
    /// The array of room members for the given room.
    ///
    /// This array contains all members for the given room, retrieved from the web service as a result
    /// of an internal real time subscription to the web service.
    public var members: [User] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    /// Returns the number of room members stored locally in the maintained collection of room members.
    public var numberOfMembers: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(room: Room, currentUser: User, persistenceController: PersistenceController, completionHandler: @escaping CompletionHandler) {
        self.roomIdentifier = room.identifier
        self.state = .degraded
        
        self.roomManagedObjectID = room.objectID
        self.userFactory = UserEntityFactory(roomID: self.roomManagedObjectID, persistenceController: persistenceController)
        
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
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
    /// Returns the room member at the given index in the maintained collection of room members.
    ///
    /// - Parameters:
    ///     - index: The index of object that should be returned from the maintained collection of
    ///     room members.
    ///
    /// - Returns: An instance of `User` from the maintained collection of room members or `nil`
    /// when the object could not be found.
    public func member(at index: Int) -> User? {
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

extension RoomMembersProvider: FetchedResultsControllerDelegate {
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        self.delegate?.roomMembersProvider(self, didAddMembersAtIndexRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        // This method intentionally does not provide any implementation.
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject object: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = object as? UserEntity, let member = try? object.snapshot() else {
            return
        }
        
        self.delegate?.roomMembersProvider(self, didRemoveMemberAtIndex: index, previousValue: member)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `RoomMembersProvider` when the maintainted collection of room members have changed.
public protocol RoomMembersProviderDelegate: class {
    
    /// Notifies the receiver that new members have been added to the maintened collection of room
    /// members.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - range: The range of added objects in the maintened collection of room members.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, didAddMembersAtIndexRange range: Range<Int>)
    
    /// Notifies the receiver that a room member from the maintened collection of room members have
    /// been removed.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - index: The index of the removed object in the maintened collection of room members.
    ///     - previousValue: The value of the room member prior to the removal.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, didRemoveMemberAtIndex index: Int, previousValue: User)
    
}
