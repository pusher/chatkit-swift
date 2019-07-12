import Foundation
import PusherPlatform

final class PCPresenceSubscription {
    let resumableSubscription: PPResumableSubscription

    init(resumableSubscription: PPResumableSubscription) {
        self.resumableSubscription = resumableSubscription
    }

    func end() {
        self.resumableSubscription.end()
    }
}
