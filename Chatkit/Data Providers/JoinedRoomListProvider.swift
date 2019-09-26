import Foundation
import CoreData
import PusherPlatform

public class JoinedRoomListProvider: NSObject, DataProvider {
    
    // MARK: - Properties
    
    public let logger: PPLogger?
    
    public weak var delegate: JoinedRoomListProviderDelegate?
    
    private let persistenceController: PersistenceController
    private let fetchedResultsController: FetchedResultsController<RoomEntity>
    
    private let roomFactory: RoomFactory
    
    // MARK: - Accessors
    
    public var rooms: [Room] {
        return self.fetchedResultsController.objects.compactMap { try? $0.snapshot() }
    }
    
    public var numberOfRooms: Int {
        return self.fetchedResultsController.numberOfObjects
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController, logger: PPLogger? = nil) {
        self.persistenceController = persistenceController
        self.logger = logger
        
        self.roomFactory = RoomFactory(persistenceController: self.persistenceController)
        
        let context = self.persistenceController.mainContext
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.identifier), ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard let lhsString = lhs as? String, let lhs = Int(lhsString), let rhsString = rhs as? String, let rhs = Int(rhsString) else {
                return .orderedSame
            }
            
            return NSNumber(value: lhs).compare(NSNumber(value: rhs))
        }
        
        self.fetchedResultsController = FetchedResultsController(sortDescriptors: [sortDescriptor], context: context)
        
        super.init()
        
        self.fetchedResultsController.delegate = self
        
        self.roomFactory.receiveInitialListOfRooms(numberOfRooms: 10, delay: 1.0)
    }
    
    // MARK: - Public methods
    
    public func room(at index: Int) -> Room? {
        return (try? self.fetchedResultsController.object(at: index)?.snapshot()) ?? nil
    }
    
}

extension JoinedRoomListProvider: FetchedResultsControllerDelegate {
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>) where ResultType : NSManagedObject {
        self.delegate?.joinedRoomListProvider(self, didJoinRoomsAtIndexRange: range)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomListProvider(self, didUpdateRoomAtIndex: index, previousValue: room)
    }
    
    func fetchedResultsController<ResultType>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject: ResultType, at index: Int) where ResultType : NSManagedObject {
        guard let object = self.fetchedResultsController.object(at: index), let room = try? object.snapshot() else {
            return
        }
        
        self.delegate?.joinedRoomListProvider(self, didLeaveRoomAtIndex: index, previousValue: room)
    }
    
}

// MARK: - Delegate

public protocol JoinedRoomListProviderDelegate: class {
    
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didJoinRoomsAtIndexRange range: Range<Int>)
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didUpdateRoomAtIndex index: Int, previousValue: Room)
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didLeaveRoomAtIndex index: Int, previousValue: Room)
    
}
