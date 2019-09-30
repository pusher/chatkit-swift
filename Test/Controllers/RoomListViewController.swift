import UIKit
import PusherChatkit

class RoomListViewController: UITableViewController {
    
    var session: ChatkitSession?
    var roomProvider: JoinedRoomsProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let session = try? ChatkitSession(instanceLocator: "test:Instance:Locator", tokenProvider: TestTokenProvider()) else {
            return
        }
        
        self.session = session
        self.roomProvider = JoinedRoomsProvider(session: session)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.roomProvider?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "displayMessages" {
            guard let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell),
                let session = self.session,
                let room = self.roomProvider?.room(at: indexPath.row),
                let messageViewController = segue.destination as? MessageViewController else {
                    return
            }
            
            messageViewController.roomDetailsProvider = RoomDetailsProvider(room: room, session: session)
        }
        else if segue.identifier == "displayRoomPicker" {
            guard let navigationController = segue.destination as? UINavigationController,
                let roomPickerViewController = navigationController.topViewController as? RoomPickerViewController,
                let session = self.session else {
                    return
            }
            
            roomPickerViewController.roomProvider = AvailableRoomsProvider(session: session)
        }
        else if segue.identifier == "displayUserPicker" {
            guard let navigationController = segue.destination as? UINavigationController,
                let userPickerViewController = navigationController.topViewController as? UserPickerViewController,
                let session = self.session else {
                    return
            }
            
            userPickerViewController.usersProvider = UsersProvider(session: session)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomProvider?.numberOfRooms ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        
        if let roomCell = cell as? TestTableViewCell {
            let room = self.roomProvider?.room(at: indexPath.row)
            
            roomCell.testLabel.text = room?.name
        }
        
        return cell
    }
}

extension RoomListViewController: JoinedRoomsProviderDelegate {
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoomsAtIndexRange range: Range<Int>) {
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
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoomAtIndex index: Int, previousValue: Room) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoomAtIndex index: Int, previousValue: Room) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
}
