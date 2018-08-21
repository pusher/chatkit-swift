import Foundation
import PusherPlatform

struct PCSharedInstanceOptions {
    let locator: String
    let tokenProvider: PPTokenProvider
    let baseClient: PPBaseClient
    let logger: PPLogger
}
