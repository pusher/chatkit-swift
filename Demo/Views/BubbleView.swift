import UIKit

class BubbleView: UIView {
    
    var corners: UIRectCorner? {
        didSet {
            self.update()
        }
    }
    
    var maximumRadius: CGFloat = 12.0 {
        didSet {
            self.update()
        }
    }
    
    var minimumRadius: CGFloat = 4.0 {
        didSet {
            self.update()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.update()
    }
    
    private func update() {
        guard let corners = self.corners else {
            self.layer.mask = nil
            return
        }
        
        let topLeftRadius = corners.contains(.topLeft) || corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let topRightRadius = corners.contains(.topRight) || corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let bottomLeftRadius = corners.contains(.bottomLeft) || corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        let bottomRightRadius = corners.contains(.bottomRight) || corners.contains(.allCorners) ? self.maximumRadius : self.minimumRadius
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds,
                                 topLeftRadius: topLeftRadius,
                                 topRightRadius: topRightRadius,
                                 bottomLeftRadius: bottomLeftRadius,
                                 bottomRightRadius: bottomRightRadius)?.cgPath
        
        self.layer.mask = mask
    }
    
}
