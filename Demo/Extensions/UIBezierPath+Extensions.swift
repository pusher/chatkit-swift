import UIKit

extension UIBezierPath {
    
    public convenience init?(roundedRect rect: CGRect, topLeftRadius: CGFloat? = nil, topRightRadius: CGFloat? = nil, bottomLeftRadius: CGFloat? = nil, bottomRightRadius: CGFloat?) {
        guard ((bottomLeftRadius ?? 0.0) + (bottomRightRadius ?? 0.0)) <= rect.size.width,
            ((topLeftRadius ?? 0.0) + (topRightRadius ?? 0.0)) <= rect.size.width,
            ((topLeftRadius ?? 0.0) + (bottomLeftRadius ?? 0.0)) <= rect.size.height,
            ((topRightRadius ?? 0.0) + (bottomRightRadius ?? 0.0)) <= rect.size.height else {
                return nil
        }
        
        self.init()
        
        let topMidpoint = CGPoint(x: rect.midX, y: rect.minY)
        self.move(to: topMidpoint)
        
        let topRightCornerCenter = CGPoint(x: rect.maxX - (topRightRadius ?? 0), y: rect.minY + (topRightRadius ?? 0))
        if let topRightRadius = topRightRadius {
            self.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
            self.addArc(withCenter: topRightCornerCenter, radius: topRightRadius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: true)
        }
        else {
            self.addLine(to: topRightCornerCenter)
        }
        
        let bottomRightCornerCenter = CGPoint(x: rect.maxX - (bottomRightRadius ?? 0), y: rect.maxY - (bottomRightRadius ?? 0))
        if let bottomRightRadius = bottomRightRadius {
            self.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
            self.addArc(withCenter: bottomRightCornerCenter, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
        }
        else {
            self.addLine(to: bottomRightCornerCenter)
        }
        
        let bottomLeftCornerCenter = CGPoint(x: rect.minX + (bottomLeftRadius ?? 0), y: rect.maxY - (bottomLeftRadius ?? 0))
        if let bottomLeftRadius = bottomLeftRadius {
            self.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
            self.addArc(withCenter: bottomLeftCornerCenter, radius: bottomLeftRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
        }
        else {
            self.addLine(to: bottomLeftCornerCenter)
        }
        
        let topLeftCornerCenter = CGPoint(x: rect.minX + (topLeftRadius ?? 0), y: rect.minY + (topLeftRadius ?? 0))
        if let topLeftRadius = topLeftRadius {
            self.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
            self.addArc(withCenter: topLeftCornerCenter, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: true)
        }
        else {
            self.addLine(to: topLeftCornerCenter)
        }

        self.close()
    }
    
}
