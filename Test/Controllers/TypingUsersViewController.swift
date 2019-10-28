import UIKit
import PusherChatkit

class TypingUsersViewController: UIViewController {
    
    @IBOutlet weak var typingUsersLabel: UILabel!
    
    var room: Room?
    var chatkit: Chatkit?
    var viewModel: TypingUsersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
        
        guard let room = self.room else {
            return
        }
        
        self.chatkit?.createTypingUsersProvider(for: room) { typingUsersProvider, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            else if let typingUsersProvider = typingUsersProvider {
                self.viewModel = TypingUsersViewModel(provider: typingUsersProvider)
                self.viewModel?.delegate = self
                
                self.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel?.delegate = nil
        
        super.viewWillAppear(animated)
    }
    
    private func reloadData() {
        self.typingUsersLabel.text = self.viewModel?.value
    }
    
}

extension TypingUsersViewController: TypingUsersViewModelDelegate {
    
    func typingUsersViewModelDidUpdateValue(_ typingUsersViewModel: TypingUsersViewModel) {
        self.reloadData()
    }
    
}
