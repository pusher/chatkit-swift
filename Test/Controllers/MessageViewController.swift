import UIKit
import PusherChatkit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var room: Room?
    var chatkit: Chatkit?
    var messagesProvider: MessagesProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let room = self.room else {
            return
        }
        
        self.chatkit?.createMessagesProvider(for: room) { messagesProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let messagesProvider = messagesProvider {
                self.messagesProvider = messagesProvider
                self.messagesProvider?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let messagesProvider = self.messagesProvider {
            self.tableView.reloadData()
            messagesProvider.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.messagesProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "displayMembers" {
            guard let membersViewController = segue.destination as? MembersViewController else {
                return
            }
            
            membersViewController.room = self.room
            membersViewController.chatkit = self.chatkit
        }
        else if segue.identifier == "displayTypingUsers" {
            guard let typingUsersViewController = segue.destination as? TypingUsersViewController else {
                return
            }
            
            typingUsersViewController.room = self.room
            typingUsersViewController.chatkit = self.chatkit
        }
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.messagesProvider?.fetchOlderMessages(numberOfMessages: 5)
    }
    
    private func scrollToBottomIfNeeded() {
        guard let lastVisibleRow = self.tableView.indexPathsForVisibleRows?.last?.row else {
            return
        }
        
        let numberOfRows = self.tableView.numberOfRows(inSection: 0)
        let lastRow = numberOfRows - 2
        let addedRow = numberOfRows - 1
        
        if lastVisibleRow == lastRow || lastVisibleRow == addedRow {
            let indexPath = IndexPath(row: addedRow, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesProvider?.numberOfMessages ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        if let messageCell = cell as? TestTableViewCell {
            let message = self.messagesProvider?.message(at: indexPath.row)
            
            if case let MessagePart.text(_, content) = message!.parts.first! {
                messageCell.testLabel.text = content
            }
        }
        
        return cell
    }
    
}

extension MessageViewController: MessagesProviderDelegate {
    
    func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveMessagesAtIndexRange range: Range<Int>) {
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
    
    func messagesProvider(_ messagesProvider: MessagesProvider, didUpdateMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func messagesProvider(_ messagesProvider: MessagesProvider, didRemoveMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    
}
