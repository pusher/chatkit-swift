import UIKit
import PusherChatkit

class MembersViewController: UITableViewController {
    
    var room: Room?
    var chatkit: Chatkit?
    var roomMembersProvider: RoomMembersProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let room = self.room else {
            return
        }
        
        self.chatkit?.createRoomMembersProvider(for: room) { roomMembersProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let roomMembersProvider = roomMembersProvider {
                self.roomMembersProvider = roomMembersProvider
                self.roomMembersProvider?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let roomMembersProvider = self.roomMembersProvider {
            self.tableView.reloadData()
            roomMembersProvider.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomMembersProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomMembersProvider?.numberOfMembers ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        
        if let memberCell = cell as? TestTableViewCell {
            let member = self.roomMembersProvider?.member(at: indexPath.row)
            
            memberCell.testLabel.text = member?.name
        }
        
        return cell
    }
}

extension MembersViewController: RoomMembersProviderDelegate {
    
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, didAddMembersAtIndexRange range: Range<Int>) {
        self.tableView.reloadData()
    }
    
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, didRemoveMemberAtIndex index: Int, previousValue: User) {
        self.tableView.reloadData()
    }
    
}
