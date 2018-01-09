//
//  AppDelegate.swift
//  Pusher Platform iOS Example
//
//  Created by Hamilton Chapman on 27/10/2016.
//  Copyright © 2016 Pusher. All rights reserved.
//

import UIKit
import PusherChatkit
import PusherPlatform

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var pusherChat: ChatManager?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let instanceLocator = "YOUR_INSTANCE_LOCATOR"

        let pusherChat = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(
                url: "YOUR_TEST_TOKEN_PROVIDER_URL",
                userId: "YOUR_USER_ID"
            ),
            logger: TestLogger()
        )

        self.pusherChat = pusherChat

        return true
    }
}

public struct TestLogger: PPLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
