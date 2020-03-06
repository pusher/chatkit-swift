import UIKit

class RoomTableViewCell: UITableViewCell, Identifiable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicatorLabel: IndicatorLabel!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    // MARK: - Identifiable
    
    static let identifier: String = "roomCell"
    
    // MARK: - Accessors
    
    var numberOfUnreadMessages: UInt64 = 0 {
        didSet {
            if numberOfUnreadMessages > 0 {
                self.leadingConstraint.isActive = true
                self.indicatorLabel.text = String(numberOfUnreadMessages)
                self.indicatorLabel.isHidden = false
            }
            else {
                self.leadingConstraint.isActive = false
                self.indicatorLabel.isHidden = true
            }
        }
    }
    
}
