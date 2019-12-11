import UIKit
import PusherChatkit

class RoomListViewController: UITableViewController {
    
    var chatkit: Chatkit?
    var viewModel: JoinedRoomsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewModel = self.viewModel {
            self.tableView.reloadData()
            viewModel.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "displayMessages" {
            guard let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell),
                let room = self.viewModel?.rooms[indexPath.row],
                let messageViewController = segue.destination as? MessageViewController else {
                    return
            }
            
            messageViewController.room = room
            messageViewController.chatkit = self.chatkit
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.rooms.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        
        if let roomCell = cell as? RoomTableViewCell, let viewModel = self.viewModel {
            let room = viewModel.rooms[indexPath.row]
            let roomName = room.name ?? "Unknown plan"

            let otherUser = self.chatkit?.members(for: room).filter { $0.identifier != self.chatkit?.currentUser?.identifier }.first
            let otherUserName = otherUser?.name ?? "Unknown user"
            
            roomCell.nameLabel.text = otherUserName + " - " + roomName
            roomCell.numberOfUnreadMessages = room.unreadCount
        }
        
        return cell
    }
    
    private func connect() {
        let tokenProvider = TestTokenProvider(instanceLocator: "test:Instance:Locator",
                                              userId: "olivia")
        
        guard let chatkit = try? Chatkit(instanceLocator: "test:Instance:Locator",
                                         tokenProvider: tokenProvider)
        else {
            return
        }
        
        self.chatkit = chatkit
        
        self.chatkit?.connect { error in
            guard error == nil else {
                return
            }
            
            self.createJoinedRoomsProvider()
        }
    }
    
    private func createJoinedRoomsProvider() {
        self.chatkit?.createJoinedRoomsViewModel { viewModel, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let viewModel = viewModel {
                self.viewModel = viewModel
                self.viewModel?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
}

extension RoomListViewController: JoinedRoomsViewModelDelegate {
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didAddRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didMoveRoomFrom oldIndex: Int, to newIndex: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        let oldIndexPath = IndexPath(row: oldIndex, section: 0)
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.moveRow(at: oldIndexPath, to: newIndexPath)
        self.tableView.endUpdates()
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [newIndexPath], with: .none)
        self.tableView.endUpdates()
    }
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didRemoveRoomAt index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
}
