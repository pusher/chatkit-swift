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

        let baseURL = "https://us1-staging.pusherplatform.io"
        let path = "services/chatkit_token_provider/v1"

        let instanceLocator = "v1:us1-staging:ca54d606-a23e-4341-9b6f-a210c65df220"
        let instanceId = instanceLocator.split(separator: ":").last!

        let pusherChat = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: "\(baseURL)/\(path)/\(instanceId)/token?instance_id=\(instanceLocator)", userId: "luka"),
            logger: HamLogger()
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
