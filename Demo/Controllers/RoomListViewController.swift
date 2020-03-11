import UIKit
import PusherChatkit

class RoomListViewController: UITableViewController {
    
    // MARK: - Properties
    
    var chatkit: Chatkit?
    private var viewModel: JoinedRoomsViewModel?
    
    // MARK: - Accessors
    
    private var rooms: [Room] {
        switch viewModel?.state {
        case let .connected(rooms, _),
             let .degraded(rooms, _, _):
            return rooms
            
        default:
            return []
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resumeUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pauseUpdates()
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    private func createViewModel() {
        self.viewModel = self.chatkit?.makeJoinedRoomsViewModel()
        self.viewModel?.delegate = self
    }
    
    private func pauseUpdates() {
        self.viewModel?.delegate = nil
    }
    
    private func resumeUpdates() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        self.tableView.reloadData()
        viewModel.delegate = self
    }
    
    private func applyChange(_ changeReason: JoinedRoomsViewModelChangeReason) {
        switch changeReason {
        case let .itemInserted(position):
            self.insertRow(atIndex: position)
            
        case let .itemChanged(position, _):
            self.reloadRow(atIndex: position)
            
        case let .itemMoved(fromPosition, toPosition):
            self.moveRow(atIndex: fromPosition, toIndex: toPosition)
            
        case let .itemRemoved(position, _):
            self.deleteRow(atIndex: position)
        }
    }
    
    private func insertRow(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .fade)
        self.tableView.endUpdates()
    }
    
    private func reloadRow(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.tableView.endUpdates()
    }
    
    private func moveRow(atIndex oldIndex: Int, toIndex newIndex: Int) {
        let oldIndexPath = IndexPath(row: oldIndex, section: 0)
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.moveRow(at: oldIndexPath, to: newIndexPath)
        self.tableView.endUpdates()
        
        self.reloadRow(atIndex: newIndex)
    }
    
    private func deleteRow(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.endUpdates()
    }
    
    private func displayError(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
}

// MARK: - Table view data source

extension RoomListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomTableViewCell.identifier, for: indexPath)
        
        if let roomCell = cell as? RoomTableViewCell {
            let room = self.rooms[indexPath.row]
            
            roomCell.nameLabel.text = room.name
            roomCell.numberOfUnreadMessages = room.unreadCount
        }
        
        return cell
    }
    
}

// MARK: - Joined rooms view model delegate

extension RoomListViewController: JoinedRoomsViewModelDelegate {
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateState state: JoinedRoomsViewModelState) {
        switch state {
        case let .initializing(error):
            if let error = error {
                self.displayError("Error encountered during initializing: \(error.localizedDescription)")
            }
            
        case let .connected(_, changeReason):
            if let changeReason = changeReason {
                self.applyChange(changeReason)
            }
            
        case let .degraded(_, error, changeReason):
            if let changeReason = changeReason {
                self.applyChange(changeReason)
            }
            
            self.displayError("Connection degraded with error: \(error.localizedDescription)")
            
        case let .closed(error):
            if let error = error {
                self.displayError("Connection closed with error: \(error.localizedDescription)")
            }
        }
    }
    
}
