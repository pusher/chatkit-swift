import Foundation

/// A provider which maintains a collection of all rooms available to the user which have been retrieved from
/// the web service.
public class AvailableRoomsProvider {
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: PagedProviderState
    
    /// The set of all rooms available to the user.
    ///
    /// This array contains all rooms available to the user which have been retrieved from the web service
    /// as a result of an implicit initial call made to the web service during the initialization of the class
    /// as well as all explicit calls triggered as a result of calling
    /// `fetchMoreRooms(numberOfRooms:completionHandler:)` method.
    public private(set) var rooms: Set<Room>
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: AvailableRoomsProviderDelegate?
    
    // MARK: - Initializers
    
    init(completionHandler: @escaping CompletionHandler) {
        self.state = .partiallyPopulated
        self.rooms = []
        
        self.fetchData(completionHandler: completionHandler)
    }
    
    // MARK: - Methods
    
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
        
        // TODO: Implement
        if let completionHandler = completionHandler {
            completionHandler(nil)
        }
    }
    
    // MARK: - Private methods
    
    private func fetchData(completionHandler: @escaping CompletionHandler) {
        // TODO: Implement
        completionHandler(nil)
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
    ///     - rooms: The set of rooms added to the maintened collection of rooms.
    func availableRoomsProvider(_ availableRoomsProvider: AvailableRoomsProvider, didReceiveRooms rooms: Set<Room>)
    
}
