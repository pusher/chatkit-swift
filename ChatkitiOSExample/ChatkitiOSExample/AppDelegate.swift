import UIKit
import PusherChatkit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var pusherChat: ChatManager?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let instanceLocator = "YOUR_INSTANCE_LOCATOR"

        let pusherChat = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: "YOUR_TOKEN_PROVIDER_URL"),
            userID: "YOUR_USER_ID",
            logger: TestLogger()
        )

        self.pusherChat = pusherChat

        // Initiate the registration process with Apple Push Notification service.
        ChatManager.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register device token with Pusher Beams service.
        ChatManager.registerDeviceToken(deviceToken)
    }
}

public struct TestLogger: PCLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PCLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
