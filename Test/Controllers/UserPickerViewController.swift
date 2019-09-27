import UIKit
import PusherChatkit

class UserPickerViewController: UITableViewController {
    
    let userProvider = TestDataFactory.createUserProvider()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.userProvider.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadMoreUsersIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.userProvider.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.loadMoreUsersIfNeeded(force: true)
    }
    
    private func loadMoreUsersIfNeeded(force: Bool = false) {
        guard force || self.userProvider.numberOfUsers == 0 else {
            return
        }
        
        self.userProvider.fetchMoreUsers(numberOfUsers: 5)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userProvider.numberOfUsers
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        if let userCell = cell as? TestTableViewCell {
            let user = self.userProvider.user(at: indexPath.row)
            
            userCell.testLabel.text = user?.name
        }
        
        return cell
    }
}

extension UserPickerViewController: UserProviderDelegate {
    
    func userProvider(_ userProvider: UserProvider, didAddUsersAtIndexRange range: Range<Int>) {
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
    
}
