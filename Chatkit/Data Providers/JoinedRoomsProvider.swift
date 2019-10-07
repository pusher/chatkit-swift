import Foundation
import CoreData
import PusherPlatform

public class JoinedRoomsProvider: DataProvider {
    
    // MARK: - Properties
    
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    private let fetchedResultsController: FetchedResultsController<RoomEntity>
    private let roomFactory: RoomEntityFactory
    
    // MARK: - Accessors
    
    public var rooms: [Room] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    public var numberOfRooms: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(currentUser: User, persistenceController: PersistenceController) {
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
        
        self.roomFactory.receiveInitialListOfRooms(numberOfRooms: 10, delay: 1.0)
    }
    
    // MARK: - Public methods
    
    public func room(at index: Int) -> Room? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
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

public protocol JoinedRoomsProviderDelegate: class {
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoomsAtIndexRange range: Range<Int>)
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoomAtIndex index: Int, previousValue: Room)
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoomAtIndex index: Int, previousValue: Room)
    
}
