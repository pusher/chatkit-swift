import Foundation
import CoreData
import PusherPlatform

public class RoomListProvider: DataProvider {
    
    // MARK: - Properties
    
    public let session: ChatkitSession
    public private(set) var isFetchingMoreRooms: Bool
    public private(set) var hasMoreRooms: Bool
    public private(set) var rooms: [Room]
    
    public weak var delegate: RoomListProviderDelegate?
    
    private let roomFactory: RoomFactory
    
    // MARK: - Accessors
    
    public var numberOfRooms: Int {
        return self.rooms.count
    }
    
    // MARK: - Initializers
    
    public init(session: ChatkitSession) {
        self.session = session
        self.isFetchingMoreRooms = false
        self.hasMoreRooms = true
        
        self.rooms = []
        self.roomFactory = RoomFactory()
    }
    
    // MARK: - Public methods
    
    public func room(at index: Int) -> Room? {
        return index >= 0 && index < self.rooms.count ? self.rooms[index] : nil
    }
    
    public func fetchMoreRooms(numberOfRooms: UInt, completionHandler: CompletionHandler? = nil) {
        guard !self.isFetchingMoreRooms else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.isFetchingMoreRooms = true
        
        let lastRoomIdentifier = self.rooms.last?.identifier ?? "-1"
        
        self.roomFactory.receiveMoreRooms(numberOfRooms: Int(numberOfRooms), lastRoomIdentifier: lastRoomIdentifier, delay: 1.0) { rooms in
            let range = Range<Int>(uncheckedBounds: (lower: self.rooms.count, upper: self.rooms.count + rooms.count))
            
            self.rooms.append(contentsOf: rooms)
            
            self.isFetchingMoreRooms = false
            
            self.delegate?.roomListProvider(self, didAddRoomsAtIndexRange: range)
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
}

// MARK: - Delegate

public protocol RoomListProviderDelegate: class {
    
    func roomListProvider(_ roomListProvider: RoomListProvider, didAddRoomsAtIndexRange range: Range<Int>)
    
}
