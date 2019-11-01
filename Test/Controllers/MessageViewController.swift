import UIKit
import PusherChatkit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var room: Room?
    var chatkit: Chatkit?
    var viewModel: MessagesViewModel?
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter
    }()
    
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
                self.viewModel = MessagesViewModel(provider: messagesProvider)
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
        self.viewModel?.fetchOlderMessages(numberOfMessages: 5)
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
    
    private func configureLoadingIndicatorCell(_ cell: UITableViewCell) {
        guard let cell = cell as? LoadingIndicatorTableViewCell else {
            return
        }
        
        cell.loadingIndicator.startAnimating()
    }
    
    private func configureDateHeaderCell(_ cell: UITableViewCell, date: Date) {
        guard let cell = cell as? TestTableViewCell else {
            return
        }
        
        cell.testLabel.text = self.dateFormatter.string(from: date)
    }
    
    private func configureMessageCell(_ cell: UITableViewCell, message: Message, groupPosition: MessagesViewModel.MessageRow.GroupPosition) {
        // TODO: Render other message parts in future.
        guard let cell = cell as? TestTableViewCell,
            let messagePart = message.parts.first else {
                return
        }
        
        if case let MessagePart.text(_, content) = messagePart {
            cell.testLabel.text = content
        }
    }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        guard let row = self.viewModel?.rows[indexPath.row] else {
            return cell
        }
        
        switch row {
        case .loadingIndicator:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingIndicatorCell", for: indexPath)
            self.configureLoadingIndicatorCell(cell)
            return cell
            
        case let .dateHeader(date):
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateHeaderCell", for: indexPath)
            self.configureDateHeaderCell(cell, date: date)
            return cell
        
        case let .message(message, groupPosition):
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
            self.configureMessageCell(cell, message: message, groupPosition: groupPosition)
            return cell
        }
    }
    
}

extension MessageViewController: MessagesViewModelDelegate {
    
    func messagesViewModelWillChangeContent(_ messagesViewModel: MessagesViewModel) {
        self.tableView.beginUpdates()
    }
    
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didAddRowAt index: Int, changeReason: MessagesViewModel.ChangeReason) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .fade)
        
//        self.scrollToBottomIfNeeded()
    }
    
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didUpdateRowAt index: Int, changeReason: MessagesViewModel.ChangeReason) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didRemoveRowAt index: Int, changeReason: MessagesViewModel.ChangeReason) {
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func messagesViewModelDidChangeContent(_ messagesViewModel: MessagesViewModel) {
        self.tableView.endUpdates()
    }
    
}
