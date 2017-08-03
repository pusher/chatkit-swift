//
//  AppDelegate.swift
//  Pusher Platform iOS Example
//
//  Created by Hamilton Chapman on 27/10/2016.
//  Copyright © 2016 Pusher. All rights reserved.
//

import UIKit
import PusherChat
import PusherPlatform

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var pusherChat: ChatManager?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let pusherChat = ChatManager(
            instanceId: "v1:api-deneb:luka-chat",
            tokenProvider: PCTestingTokenProvider(userId: "pusherino", instanceId: "v1:api-deneb:luka-chat"),
            logger: HamLogger(),
            baseClient: PPBaseClient(host: "api-deneb.pusherplatform.io", insecure: true)
        )

        self.pusherChat = pusherChat

        return true
    }
}

public struct HamLogger: PPLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
