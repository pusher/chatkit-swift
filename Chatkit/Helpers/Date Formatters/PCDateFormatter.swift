import Foundation

//
// Look at the following resources for why the date formatter is set up the
// way it is:
//
//  1. http://www.maddysoft.com/articles/dates.html
//  2. https://developer.apple.com/library/archive/qa/qa1480/_index.html
//

class PCDateFormatter {
    static let shared = PCDateFormatter()

    private let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return dateFormatter
    }()

    func formatString(_ string: String) -> Date {
        return formatter.date(from: string)!
    }
}
