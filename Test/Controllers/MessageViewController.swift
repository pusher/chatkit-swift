import UIKit
import PusherChatkit

class MessageViewController: UITableViewController {
    
    var room: Room?
    var chatkit: Chatkit?
    var roomDetailsProvider: RoomDetailsProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let room = self.room else {
            return
        }
        
        self.chatkit?.createRoomDetailsProvider(for: room) { roomDetailsProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let roomDetailsProvider = roomDetailsProvider {
                self.roomDetailsProvider = roomDetailsProvider
                self.roomDetailsProvider?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let roomDetailsProvider = self.roomDetailsProvider {
            self.tableView.reloadData()
            roomDetailsProvider.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomDetailsProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.roomDetailsProvider?.fetchOlderMessages(numberOfMessages: 5)
    }
    
    private func scrollToBottomIfNeeded() {
        guard let roomDetailsProvider = self.roomDetailsProvider else {
            return
        }
        
        let indexPath = IndexPath(row: roomDetailsProvider.numberOfMessages - 1, section: 0)
        
        if self.tableView.indexPathsForVisibleRows?.last?.row == indexPath.row {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomDetailsProvider?.numberOfMessages ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        if let messageCell = cell as? TestTableViewCell {
            let message = self.roomDetailsProvider?.message(at: indexPath.row)
            
            if case let MessagePart.text(_, content) = message!.parts.first! {
                messageCell.testLabel.text = content
            }
        }
        
        return cell
    }
    
}

extension MessageViewController: RoomDetailsProviderDelegate {
    
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didReceiveMessagesAtIndexRange range: Range<Int>) {
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
            
            self.scrollToBottomIfNeeded()
        }
    }
    
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didUpdateMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func roomDetailsProvider(_ roomDetailsProvider: RoomDetailsProvider, didRemoveMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    
}
