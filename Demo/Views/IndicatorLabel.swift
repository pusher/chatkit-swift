import UIKit

class IndicatorLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.font = UIFont.systemFont(ofSize: 11.0)
        self.textColor = UIColor.white
        self.backgroundColor = UIColor(red: 237.0 / 255.0, green: 91.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.update()
    }
    
    private func update() {
        let height: CGFloat = self.bounds.height
        let radius = CGSize(width: height / 2.0, height: height / 2.0)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: radius).cgPath
        
        self.layer.mask = mask
    }
    
}
