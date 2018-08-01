import Foundation
import PusherPlatform

public final class PCPresenceSubscription {
    public let resumableSubscription: PPResumableSubscription

    public init(resumableSubscription: PPResumableSubscription) {
        self.resumableSubscription = resumableSubscription
    }

    func end() {
        self.resumableSubscription.end()
    }
}
