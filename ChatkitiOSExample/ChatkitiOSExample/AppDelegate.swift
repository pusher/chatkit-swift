import UIKit
import PusherChatkit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var pusherChat: ChatManager?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let instanceLocator = "v1:us1:3c4de3a4-d0d3-46ad-beb2-bd45145baedb"

        let pusherChat = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(
                url: "https://us1.pusherplatform.io/services/chatkit_token_provider/v1/3c4de3a4-d0d3-46ad-beb2-bd45145baedb/token?instance_locator=v1:us1:3c4de3a4-d0d3-46ad-beb2-bd45145baedb",
                userId: "ham"
            ),
            logger: TestLogger()
        )

        self.pusherChat = pusherChat
        return true
    }
}

public struct TestLogger: PCLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PCLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
