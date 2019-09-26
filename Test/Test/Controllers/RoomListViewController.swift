import UIKit
import PusherChatkit

class RoomListViewController: UITableViewController {
    
    let roomListProvider = TestDataFactory.createJoinedRoomListProvider()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.roomListProvider.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomListProvider.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "displayMessages",
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell),
            let room = self.roomListProvider.room(at: indexPath.row),
            let messageViewController = segue.destination as? MessageViewController else {
                return
        }
        
        messageViewController.messageProvider = TestDataFactory.createMessageProvider(for: room)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomListProvider.numberOfRooms
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        
        if let roomCell = cell as? TestTableViewCell {
            let room = self.roomListProvider.room(at: indexPath.row)
            
            roomCell.messageLabel.text = room?.name
        }
        
        return cell
    }
}

extension RoomListViewController: JoinedRoomListProviderDelegate {
    
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didJoinRoomsAtIndexRange range: Range<Int>) {
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            self.tableView.reloadData()
        }
        else {
            self.tableView.beginUpdates()
            
            range.forEach {
                let indexPath = IndexPath(row: $0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
            
            self.tableView.endUpdates()
        }
    }
    
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didUpdateRoomAtIndex index: Int, previousValue: Room) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomListProvider(_ joinedRoomListProvider: JoinedRoomListProvider, didLeaveRoomAtIndex index: Int, previousValue: Room) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
}
