import UIKit
import PusherChatkit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var pusherChat: ChatManager?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let instanceLocator = "YOUR_INSTANCE_LOCATOR"

        let pusherChat = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: "YOUR_TOKEN_PROVIDER_URL"),
            userID: "YOUR_USER_ID",
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
