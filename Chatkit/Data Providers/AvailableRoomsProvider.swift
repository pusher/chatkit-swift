import Foundation
import CoreData
import PusherPlatform

/// A provider which maintains a collection of all rooms available to the user which have been retrieved from
/// the web service.
public class AvailableRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: PagedProviderState
    
    /// The array of all rooms available to the user.
    ///
    /// This array contains all rooms available to the user which have been retrieved from the web service
    /// as a result of an implicit initial call made to the web service during the initialization of the class
    /// as well as all explicit calls triggered as a result of calling
    /// `fetchMoreRooms(numberOfRooms:completionHandler:)` method.
    public private(set) var rooms: [Room]
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: AvailableRoomsProviderDelegate?
    
    private let roomFactory: RoomFactory
    
    /// Returns the number of rooms stored locally in the maintained collection of rooms.
    public var numberOfRooms: Int {
        return self.rooms.count
    }
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .partiallyPopulated
        self.rooms = []
        self.roomFactory = RoomFactory()
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
    /// Returns the room at the given index in the maintained collection of rooms.
    /// 
    /// - Parameters:
    ///     - index: The index of object that should be returned from the maintained collection of
    ///     rooms.
    ///
    /// - Returns: An instance of `Room` from the maintained collection of rooms or `nil` when
    /// the object could not be found.
    public func room(at index: Int) -> Room? {
        return index >= 0 && index < self.rooms.count ? self.rooms[index] : nil
    }
    
    /// Triggers an asynchronous call to the web service that extends the maintained collection of rooms
    /// by the given maximum number of entries.
    ///
    /// - Parameters:
    ///     - numberOfRooms: The maximum number of rooms that should be retrieved from the web
    ///     service.
    ///     - completionHandler:An optional completion handler called when the call to the web
    ///     service finishes with either a successful result or an error.
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

/// A delegate protocol that describes methods that will be called by the associated
/// `AvailableRoomsProvider` when the maintainted collection of rooms have changed.
public protocol AvailableRoomsProviderDelegate: class {
    
    /// Notifies the receiver that new rooms have been added to the maintened collection of rooms.
    ///
    /// - Parameters:
    ///     - availableRoomsProvider: The `AvailableRoomsProvider` that called
    ///     the method.
    ///     - range: The range of added objects in the maintened collection of rooms.
    func availableRoomsProvider(_ availableRoomsProvider: AvailableRoomsProvider, didAddRoomsAtIndexRange range: Range<Int>)
    
}
