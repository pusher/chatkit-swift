import UIKit
import PusherChatkit

class RoomListViewController: UITableViewController {
    
    var chatkit: Chatkit?
    var viewModel: JoinedRoomsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chatkit = try? Chatkit(instanceLocator: "test:Instance:Locator", tokenProvider: TestTokenProvider()) else {
            return
        }
        
        self.chatkit = chatkit
        
        self.chatkit?.createJoinedRoomsProvider { joinedRoomsProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let joinedRoomsProvider = joinedRoomsProvider {
                self.viewModel = JoinedRoomsViewModel(provider: joinedRoomsProvider)
                self.viewModel?.delegate = self
                
                self.tableView.reloadData()
            }
        }
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
        
//        if segue.identifier == "displayMessages" {
//            guard let cell = sender as? UITableViewCell,
//                let indexPath = self.tableView.indexPath(for: cell),
//                let room = self.roomProvider?.room(at: indexPath.row),
//                let messageViewController = segue.destination as? MessageViewController else {
//                    return
//            }
//
//            messageViewController.room = room
//            messageViewController.chatkit = self.chatkit
//        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.rooms.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        
        if let roomCell = cell as? TestTableViewCell, let viewModel = self.viewModel {
            let room = viewModel.rooms[indexPath.row]
            
            roomCell.testLabel.text = room.name
        }
        
        return cell
    }
}

extension RoomListViewController: JoinedRoomsViewModelDelegate {
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didAddRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didUpdateRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        
        switch changeReason {
        case .dataUpdated:
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            
        case let .messageReceived(previousIndex):
            let previousIndexPath = IndexPath(row: previousIndex, section: 0)
            self.tableView.moveRow(at: previousIndexPath, to: indexPath)
            
        default:
            break
        }
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomsViewModel(_ joinedRoomsViewModel: JoinedRoomsViewModel, didRemoveRoomAtIndex index: Int, changeReason: JoinedRoomsViewModel.ChangeReason) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
}
