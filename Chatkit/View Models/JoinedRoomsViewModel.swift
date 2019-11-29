import Foundation

/// A view model which provides a collection of all `Room`s joined by the user.
///
/// This class is intended to allow easy binding to a UICollectionView or UITableView.
///
/// The rooms are sorted in descending order of the time of their last message, or their creation time if they contain no messages.
public class JoinedRoomsViewModel {
    
    // MARK: - Properties
    
    private let provider: JoinedRoomsProvider
    
    /// The array of all rooms joined by the user.
    public private(set) var rooms: [Room]
    
    /// The current state of the provider used by the view model as the data source.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the provider related to the real time web service.
    ///     - paged: The current state of the provider related to the non-real time web service.
    public var state: (realTime: RealTimeProviderState, paged: PagedProviderState) {
        return self.provider.state
    }
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: JoinedRoomsViewModelDelegate?
    
    // MARK: - Initializers
    
    init(provider: JoinedRoomsProvider) {
        self.rooms = provider.rooms
        
        self.provider = provider
        self.provider.delegate = self
    }
    
    // MARK: - Methods
    
    /// Triggers an asynchronous call to the web service that retrieves a batch of historical messages
    /// currently not present in the maintained collection of messages.
    ///
    /// - Parameters:
    ///     - numberOfMessages: The maximum number of messages that should be retrieved from
    ///     the web service.
    ///     - completionHandler:An optional completion handler called when the call to the web
    ///     service finishes with either a successful result or an error.
    public func fetchMoreRooms(completionHandler: CompletionHandler? = nil) {
        guard self.provider.state.paged == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
            
            return
        }
        
        self.provider.fetchMoreRooms(completionHandler: completionHandler)
    }
    
    // MARK: - Private methods
    
    private func index(of room: Room) -> Int? {
        return self.rooms.firstIndex { storedRoom -> Bool in
            return storedRoom.identifier == room.identifier
        }
    }
    
}

// MARK: - JoinedRoomsProviderDelegate

extension JoinedRoomsViewModel: JoinedRoomsProviderDelegate {
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didReceiveNewActiveRoom room: Room, at index: Int) {
        self.delegate?.joinedRoomsViewModelWillChangeContent(self)
        
        self.rooms.insert(room, at: index)
        
        self.delegate?.joinedRoomsViewModel(self, didAddRoomAt: index, changeReason: .userJoined)
        
        self.delegate?.joinedRoomsViewModelDidChangeContent(self)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didReceiveMoreRooms rooms: [Room]) {
        // TODO: Implement when required.
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room) {
        guard let index = self.index(of: previousValue) else {
            return
        }
        
        self.delegate?.joinedRoomsViewModelWillChangeContent(self)
        
        let currentMessage = room.lastMessage
        let previousMessage = previousValue.lastMessage
        let changeReason: JoinedRoomsViewModel.ChangeReason = currentMessage != nil && currentMessage?.identifier != previousMessage?.identifier ? .messageReceived : .dataUpdated
        
        self.rooms[index] = room
        
        self.delegate?.joinedRoomsViewModel(self, didUpdateRoomAt: index, changeReason: changeReason)
        
        self.delegate?.joinedRoomsViewModelDidChangeContent(self)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didMoveRoom room: Room, from oldIndex: Int, to newIndex: Int, previousValue: Room) {
        self.delegate?.joinedRoomsViewModelWillChangeContent(self)
        
        let currentMessage = room.lastMessage
        let previousMessage = previousValue.lastMessage
        let changeReason: JoinedRoomsViewModel.ChangeReason = currentMessage != nil && currentMessage?.identifier != previousMessage?.identifier ? .messageReceived : .dataUpdated
        
        self.rooms.remove(at: oldIndex)
        self.rooms.insert(room, at: newIndex)
        
        self.delegate?.joinedRoomsViewModel(self, didMoveRoomFrom: oldIndex, to: newIndex, changeReason: changeReason)
        
        self.delegate?.joinedRoomsViewModelDidChangeContent(self)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didRemoveRoom room: Room) {
        guard let index = self.index(of: room) else {
            return
        }
        
        self.delegate?.joinedRoomsViewModelWillChangeContent(self)
        
        self.rooms.remove(at: index)
        
        self.delegate?.joinedRoomsViewModel(self, didRemoveRoomAt: index, changeReason: .userLeft)
        
        self.delegate?.joinedRoomsViewModelDidChangeContent(self)
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `JoinedRoomsViewModel` when the maintainted collection of rooms have changed.
public protocol JoinedRoomsViewModelDelegate: class {
    
    /// Called before a batch of changes are made to the collection of rooms.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    func joinedRoomsViewModelWillChangeContent(_ joinedRoomsViewModel: JoinedRoomsViewModel)
    
    /// Notifies the receiver that a new room has been added to the maintened collection of rooms.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - index: The index of the room added to the maintened collection of rooms.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didAddRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - index: The index of the room updated in the maintened collection of rooms.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been moved.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - oldIndex: The old index of the room before the move.
    ///     - newIndex: The new index of the room after the move.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didMoveRoomFrom oldIndex: Int, to newIndex: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been removed.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - index: The index of the room removed from the maintened collection of rooms.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didRemoveRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Called after a batch of changes are made to the collection of rooms.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    func joinedRoomsViewModelDidChangeContent(_ joinedRoomsViewModel: JoinedRoomsViewModel)
    
}

// MARK: - Change Reason

public extension JoinedRoomsViewModel {
    
    // TODO: Define change reasons.
    /// An enumeration representing semantic reasons that might trigger a change
    /// in the `JoinedRoomsViewModel` class.
    enum ChangeReason {
        
        /// The user joined the room.
        case userJoined
        
        /// The user left the room.
        case userLeft
        
        /// A new message received by the room.
        case messageReceived
        
        /// A new value of `name` or `customData` properties received by the room.
        case dataUpdated
        
    }
    
}
