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

        let pusherChat = ChatManager(
            id: "some-app-id",
            baseClient: PPBaseClient(
//                cluster: "api.kube.pusherplatform.io",
                cluster: "localhost",
                port: 10443,
                insecure: true
            )
        )
//        let pusherChat = ChatAPI(id: "some-app-id", baseClient: BaseClient(cluster: "localhost", port: 10443, insecure: true))

        self.pusherChat = pusherChat

//        (self.pusherChat?.app.logger as? PPDefaultLogger)?.minimumLogLevel = .verbose

        return true
    }
}
