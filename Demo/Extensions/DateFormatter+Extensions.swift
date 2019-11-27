import Foundation

internal extension DateFormatter {
    
    // MARK: - Properties
    
    static let header: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        return dateFormatter
    }()
    
    static let time: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter
    }()
    
}
