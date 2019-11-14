import UIKit

class RoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicatorLabel: IndicatorLabel!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
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
