import UIKit
import PusherChatkit

class RoomPickerViewController: UITableViewController {
    
    var roomProvider: AvailableRoomsProvider?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.roomProvider?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadMoreRoomsIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomProvider?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.loadMoreRoomsIfNeeded(force: true)
    }
    
    private func loadMoreRoomsIfNeeded(force: Bool = false) {
        guard force || self.roomProvider?.numberOfRooms == 0 else {
            return
        }
        
        self.roomProvider?.fetchMoreRooms(numberOfRooms: 5)
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

extension RoomPickerViewController: AvailableRoomsProviderDelegate {
    
    func availableRoomsProvider(_ availableRoomsProvider: AvailableRoomsProvider, didAddRoomsAtIndexRange range: Range<Int>) {
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
