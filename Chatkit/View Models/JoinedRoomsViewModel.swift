import Foundation

/// A view model which provides a collection of all `Room`s joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsViewModel(...)`
///
/// This class is intended to be bound to a UICollectionView or UITableView.
///
/// ## What is provided
///
/// The ViewModel exposes an array, `rooms: [Room]` which presents the rooms that the current user is a member
/// of in descending order of the time of their last message, or their creation time if they contain no messages.
///
/// Each item in the `rooms` array can be used to populate a cell in a `UITableView` or `UICollectionView`.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` changes, implement the `JoinedRoomsViewModelDelegate` protocol and assign the `JoinedRoomsViewModel.delegate` property.
///
/// Note that when the view model is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the ViewModel
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class JoinedRoomsViewModel {
    
    // MARK: - Properties
    
    private let repository: JoinedRoomsRepository
    
    /// The array of all rooms joined by the user.
    public private(set) var rooms: [Room]
    
    /// The current state of the repository used by the view model as the data source.
//    public var state: RealTimeRepositoryState {
//        return self.repository.state
//    }
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: JoinedRoomsViewModelDelegate?
    
    // MARK: - Initializers
    
    init(repository: JoinedRoomsRepository) {
        self.rooms = []
        
        self.repository = repository
//        self.repository.delegate = self
        
        self.reload()
    }
    
    // MARK: - Private methods
    
    private func reload() {
//        self.rooms = Array(self.repository.rooms)
//        self.sort()
    }
    
    private func sort() {
//        self.rooms.sort { lhs, rhs -> Bool in
//            if let lhsLastMessage = lhs.lastMessage, let rhsLastMessage = rhs.lastMessage {
//                return lhsLastMessage.createdAt > rhsLastMessage.createdAt
//            }
//            else {
//                return lhs.createdAt > rhs.createdAt
//            }
//        }
    }
    
    private func index(of room: Room) -> Int? {
        return self.rooms.firstIndex { storedRoom -> Bool in
            return storedRoom.identifier == room.identifier
        }
    }
    
}

// MARK: - JoinedRoomsRepositoryDelegate

/// :nodoc:
//extension JoinedRoomsViewModel: JoinedRoomsRepositoryDelegate {
//
//    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didJoinRoom room: Room) {
//        // TODO: Optimize if necessary
//
//        self.rooms.append(room)
//        self.sort()
//
//        guard let index = self.index(of: room) else {
//            return
//        }
//
//        self.delegate?.joinedRoomsViewModel(self, didAddRoomAt: index, changeReason: .userJoined)
//    }
//
//    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateRoom room: Room, previousValue: Room) {
        // TODO: Optimize if necessary
        
//        guard let previousIndex = self.index(of: previousValue) else {
//            return
//        }
//        
//        self.rooms[previousIndex] = room
//        self.sort()
//        
//        guard let currentIndex = self.index(of: room) else {
//            return
//        }
//        
//        let currentMessage = room.lastMessage
//        let previousMessage = previousValue.lastMessage
//        let changeReason: JoinedRoomsViewModel.ChangeReason = currentMessage != nil && currentMessage?.identifier != previousMessage?.identifier ? .messageReceived : .dataUpdated
//        
//        if currentIndex != previousIndex {
//            self.delegate?.joinedRoomsViewModel(self, didMoveRoomFrom: previousIndex, to: currentIndex, changeReason: changeReason)
//        }
//        else {
//            self.delegate?.joinedRoomsViewModel(self, didUpdateRoomAt: currentIndex, changeReason: changeReason)
//        }
//    }
//
//    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didLeaveRoom room: Room) {
//        guard let index = self.index(of: room) else {
//            return
//        }
//
//        self.rooms.remove(at: index)
//
//        self.delegate?.joinedRoomsViewModel(self, didRemoveRoomAt: index, changeReason: .userLeft)
//    }
//
//}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `JoinedRoomsViewModel` when the maintainted collection of rooms have changed.
public protocol JoinedRoomsViewModelDelegate: class {
    
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
