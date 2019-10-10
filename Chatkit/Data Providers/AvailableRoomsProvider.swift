import Foundation
import CoreData
import PusherPlatform

public class AvailableRoomsProvider: DataProvider {
    
    // MARK: - Properties
    
    public private(set) var state: PagedCollectionState
    public private(set) var rooms: [Room]
    
    public weak var delegate: AvailableRoomsProviderDelegate?
    
    private let roomFactory: RoomFactory
    
    // MARK: - Accessors
    
    public var numberOfRooms: Int {
        return self.rooms.count
    }
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .initializing
        self.rooms = []
        self.roomFactory = RoomFactory()
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Public methods
    
    public func room(at index: Int) -> Room? {
        return index >= 0 && index < self.rooms.count ? self.rooms[index] : nil
    }
    
    public func fetchMoreRooms(numberOfRooms: UInt, completionHandler: CompletionHandler? = nil) {
        guard self.state == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        self.state = .fetching
        
        let lastRoomIdentifier = self.rooms.last?.identifier ?? "-1"
        
        self.roomFactory.receiveRooms(numberOfRooms: Int(numberOfRooms), lastRoomIdentifier: lastRoomIdentifier, delay: 1.0) { rooms in
            let range = Range<Int>(uncheckedBounds: (lower: self.rooms.count, upper: self.rooms.count + rooms.count))
            
            self.rooms.append(contentsOf: rooms)
            
            self.state = .partiallyPopulated
            
            self.delegate?.availableRoomsProvider(self, didAddRoomsAtIndexRange: range)
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        guard self.state == .initializing else {
            return
        }
        
        self.state = .fetching
        
        self.roomFactory.receiveRooms(numberOfRooms: 5, lastRoomIdentifier: "-1", delay: 1.0) { rooms in
            self.rooms.append(contentsOf: rooms)
            
            self.state = .partiallyPopulated
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}

// MARK: - Delegate

public protocol AvailableRoomsProviderDelegate: class {
    
    func availableRoomsProvider(_ availableRoomsProvider: AvailableRoomsProvider, didAddRoomsAtIndexRange range: Range<Int>)
    
}
