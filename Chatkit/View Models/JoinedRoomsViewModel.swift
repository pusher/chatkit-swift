import Foundation

/// A view model which provides a collection of all `Room`s joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsViewModel(...)`
///
/// This class is intended to be bound to a UICollectionView or UITableView.
///
/// ## What is provided
///
/// The ViewModel exposes  a state with an array of `rooms` which presents the rooms that the current
/// user is a member of in descending order of the time of their last message, or their creation time if they
/// contain no messages.
///
/// Each item in the `rooms` array can be used to populate a cell in a `UITableView`
/// or `UICollectionView`.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` or the `state` of the connection changes,
/// implement the `JoinedRoomsViewModelDelegate` protocol and assign
/// the `JoinedRoomsViewModel.delegate` property.
///
/// ## Understanding the `state` of the ViewModel
///
/// The `state` property describes the state of the live update connection, either
///   - `.initializing`: awaiting the initial set of data, or
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems, or
///   - `.closed`: the connection is closed, no further updates available.
public protocol JoinedRoomsViewModel: AnyObject {
    
    /// The current state of the view model.
    var state: JoinedRoomsViewModelState { get }
    
    /// The object that is notified when the `state` has changed.
    var delegate: JoinedRoomsViewModelDelegate? { get set }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `state` property of a `JoinedRoomsViewModel`
/// has changed.
public protocol JoinedRoomsViewModelDelegate: AnyObject {
    
    /// Notifies the receiver that the `state` of the view model has changed.
    ///
    /// - Parameters:
    ///     - joinedRoomsViewModel: The `JoinedRoomsViewModel` that called the method.
    ///     - state: The updated value of the `state`.
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateState state: JoinedRoomsViewModelState)
    
}

// MARK: - Concrete implementation

class ConcreteJoinedRoomsViewModel: JoinedRoomsViewModel {
    
    // MARK: - Properties
    
    private let repository: JoinedRoomsRepository
    
    public private(set) var state: JoinedRoomsViewModelState {
        didSet {
            if state != oldValue {
                DispatchQueue.main.async {
                    self.delegate?.joinedRoomsViewModel(self, didUpdateState: self.state)
                }
            }
        }
    }
    
    public weak var delegate: JoinedRoomsViewModelDelegate?
    
    // MARK: - Initializers
    
    init(repository: JoinedRoomsRepository) {
        self.state = Self.state(forRepositoryState: repository.state)
        self.repository = repository
        self.repository.delegate = self
    }
    
    // MARK: - Private methods
    
    private static func state(forRepositoryState repositoryState: JoinedRoomsRepositoryState, previousState: JoinedRoomsViewModelState? = nil) -> JoinedRoomsViewModelState {
        var previousRooms: [Room]? = nil
        
        switch previousState {
        case let .connected(rooms, _),
             let .degraded(rooms, _, _):
            previousRooms = rooms
            
        case .initializing,
             .closed,
             .none:
            break
        }
        
        return JoinedRoomsViewModelState(repositoryState: repositoryState, previousRooms: previousRooms)
    }
    
}

// MARK: - JoinedRoomsRepositoryDelegate

/// :nodoc:
extension ConcreteJoinedRoomsViewModel: JoinedRoomsRepositoryDelegate {
    
    public func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepositoryState) {
        self.state = Self.state(forRepositoryState: state, previousState: self.state)
    }
    
}
