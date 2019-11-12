import UIKit

class BubbleView: UIView {
    
    var corners: UIRectCorner? {
        didSet {
            self.update()
        }
    }
    
    var radius = CGSize(width: 10.0, height: 10.0) {
        didSet {
            self.update()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.update()
    }
    
    private func update() {
        if let corners = corners {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: self.radius).cgPath
            
            self.layer.mask = mask
        }
        else {
            self.layer.mask = nil
        }
    }
    
}
