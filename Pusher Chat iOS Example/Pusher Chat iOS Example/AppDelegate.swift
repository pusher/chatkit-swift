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

        let instanceId = "v1:api-deneb:2f354c91-269f-4820-93d2-5441219fdd23"
        let pusherChat = ChatManager(
            instanceId: instanceId,
            tokenProvider: PCTokenProvider(url: "https://chatkit-test-token-provider.herokuapp.com/token?instance_id=v1:us1:1234", userId: "test"),
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
