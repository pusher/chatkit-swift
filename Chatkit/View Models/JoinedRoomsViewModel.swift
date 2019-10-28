import Foundation

/// A view model which provides a collection of all rooms joined by the user.
///
/// The collection of all rooms joined by the user is sorted by the view model based on the value
/// of `createdAt` property of last message on the room when such message is available. When a room
/// does not contain any messages, the view model uses the value of `createdAt` property of the room
/// to determine the position of the room in the collection.
public class JoinedRoomsViewModel {
    
    // MARK: - Properties
    
    private let provider: JoinedRoomsProvider
    
    /// The array of all rooms joined by the user.
    public private(set) var rooms: [Room]
    
    /// The object that is notified when the content of the maintained collection of rooms changed.
    public weak var delegate: JoinedRoomsViewModelDelegate?
    
    // MARK: - Initializers
    
    /// Designated initializer for the class.
    ///
    /// - Parameters:
    ///     - provider: The joined rooms provider used as the source of data.
    public init(provider: JoinedRoomsProvider) {
        self.rooms = []
        
        self.provider = provider
        self.provider.delegate = self
        
        self.reload()
    }
    
    // MARK: - Private methods
    
    private func reload() {
        self.rooms = Array(self.provider.rooms)
        self.sort()
    }
    
    private func sort() {
        self.rooms.sort { lhs, rhs -> Bool in
            if let lhsLastMessage = lhs.lastMessage, let rhsLastMessage = rhs.lastMessage {
                return lhsLastMessage.createdAt < rhsLastMessage.createdAt
            }
            else {
                return lhs.createdAt < rhs.createdAt
            }
        }
    }
    
    private func index(of room: Room) -> Int? {
        return self.rooms.firstIndex { storedRoom -> Bool in
            return storedRoom.identifier == room.identifier
        }
    }
    
}

extension JoinedRoomsViewModel: JoinedRoomsProviderDelegate {
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room) {
        // TODO: Optimize if necessary
        
        self.rooms.append(room)
        self.sort()
        
        guard let index = self.index(of: room) else {
            return
        }
        
        self.delegate?.joinedRoomsViewModel(self, didAddRoomAtIndex: index, changeReason: .userJoined)
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room) {
        // TODO: Optimize if necessary
        
        guard let previousIndex = self.index(of: previousValue) else {
            return
        }
        
        self.rooms[previousIndex] = room
        self.sort()
        
        guard let currentIndex = self.index(of: room) else {
            return
        }
        
        if let currentLastMessage = room.lastMessage,
            let previousLastMessage = previousValue.lastMessage,
            currentLastMessage.createdAt == previousLastMessage.createdAt {
            self.delegate?.joinedRoomsViewModel(self, didUpdateRoomAtIndex: currentIndex, changeReason: .messageReceived(previousIndex))
        }
        else {
            self.delegate?.joinedRoomsViewModel(self, didUpdateRoomAtIndex: currentIndex, changeReason: .dataUpdated)
        }
    }
    
    public func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room) {
        guard let index = self.index(of: room) else {
            return
        }
        
        self.rooms.remove(at: index)
        
        self.delegate?.joinedRoomsViewModel(self, didRemoveRoomAtIndex: index, changeReason: .userLeft)
    }
    
}

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
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didAddRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - index: The index of the room updated in the maintened collection of rooms.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been removed.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - index: The index of the room removed from the maintened collection of rooms.
    ///     - changeReason: The semantic reson that triggered the change.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didRemoveRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason)
    
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
        ///
        /// - Parameters:
        ///     - index: The previous index of the room before the message has been received.
        case messageReceived(Int)
        
        /// A new value of `name` or `userData` properties received by the room.
        case dataUpdated
        
    }
    
}
