import UIKit
import PusherChatkit

class TypingUsersViewController: UITableViewController {
    
    var room: Room?
    var chatkit: Chatkit?
    var typingUsersProvider: TypingUsersProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let room = self.room else {
            return
        }
        
        self.chatkit?.createTypingUsersProvider(for: room) { typingUsersProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let typingUsersProvider = typingUsersProvider {
                self.typingUsersProvider = typingUsersProvider
                self.typingUsersProvider?.delegate = self
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let typingUsersProvider = self.typingUsersProvider {
            self.tableView.reloadData()
            typingUsersProvider.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.typingUsersProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.typingUsersProvider?.numberOfTypingUsers ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        if let userCell = cell as? TestTableViewCell {
            let user = self.typingUsersProvider?.typingUser(at: indexPath.row)
            
            userCell.testLabel.text = user?.name
        }
        
        return cell
    }
}

extension TypingUsersViewController: TypingUsersProviderDelegate {
    
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, didAddTypingUsersAtIndexRange range: Range<Int>) {
        self.tableView.reloadData()
    }
    
    func typingUsersProvider(_ typingUsersProvider: TypingUsersProvider, didRemoveTypingUserAtIndex index: Int, previousValue: User) {
        self.tableView.reloadData()
    }
    
}
