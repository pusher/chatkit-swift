import UIKit

class BubbleView: UIView {
    
    var corners: UIRectCorner = [] {
        didSet {
            self.update()
        }
    }
    
    var maximumRadius: CGFloat = 12.0 {
        didSet {
            self.update()
        }
    }
    
    var minimumRadius: CGFloat = 6.0 {
        didSet {
            self.update()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.update()
    }
    
    private func update() {
        let topLeftRadius = self.corners.contains(.topLeft) || self.corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let topRightRadius = self.corners.contains(.topRight) || self.corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let bottomLeftRadius = self.corners.contains(.bottomLeft) || self.corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let bottomRightRadius = self.corners.contains(.bottomRight) || self.corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds,
                                 topLeftRadius: topLeftRadius,
                                 topRightRadius: topRightRadius,
                                 bottomLeftRadius: bottomLeftRadius,
                                 bottomRightRadius: bottomRightRadius)?.cgPath
        
        self.layer.mask = mask
    }
    
}
