import Foundation

internal extension DateFormatter {
    
    private static let iso8601DateFormatter: DateFormatter = {
        let iso8601DateFormatter = DateFormatter()
        iso8601DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return iso8601DateFormatter
    }()

    private static let iso8601WithoutMillisecondsDateFormatter: DateFormatter = {
        let iso8601DateFormatter = DateFormatter()
        iso8601DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return iso8601DateFormatter
    }()

    static func date(fromISO8601String string: String) -> Date? {
        if let dateWithoutMilliseconds = iso8601WithoutMillisecondsDateFormatter.date(from: string) {
            return dateWithoutMilliseconds
        }
        
        if let dateWithMilliseconds = iso8601DateFormatter.date(from: string) {
            return dateWithMilliseconds
        }

        return nil
    }
    
}
