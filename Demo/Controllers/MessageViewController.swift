import UIKit
import PusherChatkit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var room: Room?
    var chatkit: Chatkit?
    var messagesViewModel: MessagesViewModel?
    var typingUsersViewModel: TypingUsersViewModel?
    
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
        
        self.title = room.name ?? "Messages"
        
        self.chatkit?.createMessagesProvider(for: room) { messagesProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let messagesProvider = messagesProvider {
                self.messagesViewModel = MessagesViewModel(provider: messagesProvider)
                self.messagesViewModel?.delegate = self
                
                self.tableView.reloadData()
            }
        }
        
        self.chatkit?.createTypingUsersProvider(for: room) { typingUsersProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let typingUsersProvider = typingUsersProvider {
                self.typingUsersViewModel = TypingUsersViewModel(provider: typingUsersProvider)
                self.typingUsersViewModel?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let messagesViewModel = self.messagesViewModel, let typingUsersViewModel = self.typingUsersViewModel {
            self.tableView.reloadData()
            
            messagesViewModel.delegate = self
            typingUsersViewModel.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.messagesViewModel?.delegate = nil
        self.typingUsersViewModel?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.messagesViewModel?.fetchOlderMessages(numberOfMessages: 5)
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
    
    private func configureTypingUsersCell(_ cell: UITableViewCell) {
        guard let cell = cell as? TextTableViewCell else {
            return
        }
        
        cell.contentLabel.text = self.typingUsersViewModel?.value
    }
    
    private func configureDateHeaderCell(_ cell: UITableViewCell, date: Date) {
        guard let cell = cell as? TextTableViewCell else {
            return
        }
        
        cell.contentLabel.text = self.dateFormatter.string(from: date)
    }
    
    private func configureMessageCell(_ cell: UITableViewCell, message: Message, groupPosition: MessagesViewModel.MessageRow.GroupPosition) {
        // TODO: Render other message parts in future.
        guard let cell = cell as? MessageTableViewCell,
            let messagePart = message.parts.first,
            let currentUser = self.chatkit?.currentUser else {
                return
        }
        
        if case let MessagePart.text(_, content) = messagePart {
            cell.sender = message.sender.identifier == currentUser.identifier ? .currentUser : .otherUser
            cell.groupPosition = groupPosition
            cell.contentLabel.text = content
        }
    }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.messagesViewModel?.rows.count ?? 0
        }
        else {
            return self.typingUsersViewModel?.value != nil ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let row = self.messagesViewModel?.rows[indexPath.row] else {
                return tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
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
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "typingUsersCell", for: indexPath)
            self.configureTypingUsersCell(cell)
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

extension MessageViewController: TypingUsersViewModelDelegate {
    
    func typingUsersViewModelDidUpdateValue(_ typingUsersViewModel: TypingUsersViewModel) {
        self.tableView.beginUpdates()
        
        self.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .fade)
        
        self.tableView.endUpdates()
    }
    
}
