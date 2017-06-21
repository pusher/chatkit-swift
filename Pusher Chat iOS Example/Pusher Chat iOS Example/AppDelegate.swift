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
    public var pusherChat: ChatManager? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let kubeBaseClient = PPBaseClient(cluster: "api-ceres.pusherplatform.io")

        let localhostBaseClient = PPBaseClient(
            cluster: "localhost",
            port: 10443,
            insecure: true
        )

        let pusherChat = ChatManager(
            id: "some-app-id",
            tokenProvider: PCTestingTokenProvider(userId: "ham", serviceId: "some-app-id"),
            logger: HamLogger(),
            baseClient: localhostBaseClient
        )

        self.pusherChat = pusherChat

//        (self.pusherChat?.app.logger as? PPDefaultLogger)?.minimumLogLevel = .verbose

        return true
    }
}


public struct HamLogger: PPLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
        guard logLevel >= .debug else { return }
        print("\(message())")
    }
}
