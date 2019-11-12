import UIKit
import PusherChatkit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bubbleView: BubbleView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint?
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var groupPosition: MessagesViewModel.MessageRow.GroupPosition = .single {
        didSet {
            self.updateBubble()
        }
    }
    
    var sender: Sender = .currentUser {
        didSet {
            self.updateBubble()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateBubble()
    }
    
    private func updateBubble() {
        guard let leadingConstraint = self.leadingConstraint,
            let trailingConstraint = self.trailingConstraint else {
                return
        }
        
        self.contentView.removeConstraints([leadingConstraint, trailingConstraint])
        
        switch self.sender {
        case .currentUser:
            self.bubbleView.backgroundColor = UIColor(red: 71.0 / 255.0, green: 149.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
            self.contentLabel.textColor = UIColor.white
            
            self.leadingConstraint = self.contentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 50.0)
            self.trailingConstraint = self.contentView.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor, constant: 25.0)
            
            self.leadingConstraint?.isActive = true
            self.trailingConstraint?.isActive = true
            
        case .otherUser:
            self.bubbleView.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
            self.contentLabel.textColor = UIColor.black
            
            self.leadingConstraint = self.contentLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25.0)
            self.trailingConstraint = self.contentView.trailingAnchor.constraint(greaterThanOrEqualTo: self.contentLabel.trailingAnchor, constant: 50.0)
            
            self.leadingConstraint?.isActive = true
            self.trailingConstraint?.isActive = true
        }
        
        let minimumSpacing: CGFloat = 1.0
        let maximumSpacing: CGFloat = 4.0
        
        switch self.groupPosition {
        case .single:
            self.bubbleView.corners = .allCorners
            self.topConstraint.constant = maximumSpacing
            self.bottomConstraint.constant = maximumSpacing
            
        case .top:
            self.bubbleView.corners = [.topLeft, .topRight]
            self.topConstraint.constant = maximumSpacing
            self.bottomConstraint.constant = minimumSpacing
        
        case .bottom:
            self.bubbleView.corners = [.bottomLeft, .bottomRight]
            self.topConstraint.constant = minimumSpacing
            self.bottomConstraint.constant = maximumSpacing
        
        case .middle:
            self.bubbleView.corners = nil
            self.topConstraint.constant = minimumSpacing
            self.bottomConstraint.constant = minimumSpacing
        }
    }
    
}

extension MessageTableViewCell {
    
    enum Sender {
        
        case currentUser
        case otherUser
        
    }
    
}
