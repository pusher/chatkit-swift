import UIKit
import PusherChatkit

class RoomPickerViewController: UITableViewController {
    
    let roomListProvider = TestDataFactory.createRoomListProvider()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.roomListProvider.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadMoreRoomsIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.roomListProvider.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        self.loadMoreRoomsIfNeeded(force: true)
    }
    
    private func loadMoreRoomsIfNeeded(force: Bool = false) {
        guard force || self.roomListProvider.numberOfRooms == 0 else {
            return
        }
        
        self.roomListProvider.fetchMoreRooms(numberOfRooms: 5)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomListProvider.numberOfRooms
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        
        if let roomCell = cell as? TestTableViewCell {
            let room = self.roomListProvider.room(at: indexPath.row)
            
            roomCell.testLabel.text = room?.name
        }
        
        return cell
    }
}

extension RoomPickerViewController: RoomListProviderDelegate {
    
    func roomListProvider(_ roomListProvider: RoomListProvider, didAddRoomsAtIndexRange range: Range<Int>) {
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
