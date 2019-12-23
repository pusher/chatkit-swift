import Foundation

extension Date {
    
    init?(fromISO8601String dateString: String) {
        guard let date = DateFormatter.date(fromISO8601String: dateString) else {
            return nil
        }
        self = date
    }
    
}
