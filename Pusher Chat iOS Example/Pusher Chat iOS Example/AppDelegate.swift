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

        let localhostBaseClient = PPBaseClient(
            host: "",
            insecure: true
        )

        let pusherChat = ChatManager(
            id: "some-instance-id",

            tokenProvider: PCTestingTokenProvider(userId: "ham", serviceId: "some-instance-id"),
            logger: HamLogger(),
            baseClient: localhostBaseClient
        )

        self.pusherChat = pusherChat

        //        (self.pusherChat?.instance.logger as? PPDefaultLogger)?.minimumLogLevel = .verbose

        return true
    }
}

public struct HamLogger: PPLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
