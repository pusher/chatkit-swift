import UIKit
import PusherChatkit

class MessageViewController: UITableViewController {
    
    var messageProvider: MessageProvider?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.messageProvider?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.messageProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.messageProvider?.fetchOlderMessages(numberOfMessages: 5)
    }
    
    private func scrollToBottomIfNeeded() {
        guard let messageProvider = self.messageProvider else {
            return
        }
        
        let indexPath = IndexPath(row: messageProvider.numberOfAvailableMessages - 1, section: 0)
        
        if self.tableView.indexPathsForVisibleRows?.last?.row == indexPath.row {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageProvider?.numberOfAvailableMessages ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        if let messageCell = cell as? TestTableViewCell {
            let message = self.messageProvider?.message(at: indexPath.row)
            
            if case let MessagePart.text(_, content) = message!.parts.first! {
                messageCell.testLabel.text = content
            }
        }
        
        return cell
    }
    
}

extension MessageViewController: MessageProviderDelegate {
    
    func messageProvider(_ messageProvider: MessageProvider, didReceiveMessagesWithRange range: Range<Int>) {
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
    
    func messageProvider(_ messageProvider: MessageProvider, didChangeMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    func messageProvider(_ messageProvider: MessageProvider, didDeleteMessageAtIndex index: Int, previousValue: Message) {
        self.tableView.beginUpdates()
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        self.tableView.endUpdates()
    }
    
    
}
