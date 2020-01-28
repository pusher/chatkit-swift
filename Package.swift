// swift-tools-version:5.0

import PackageDescription

let package = Package(name: "PusherChatkit",
                      platforms: [.macOS(.v10_12),
                                  .iOS(.v10),
                                  .tvOS(.v10),
                                  .watchOS(.v3)],
                      products: [.library(name: "PusherChatkit",
                                          targets: ["PusherChatkit"])],
                      dependencies: [.package(url: "https://github.com/pusher/pusher-platform-swift.git",
                                              .branch("v1")),
                                     .package(url: "https://github.com/pusher/push-notifications-swift.git",
                                              from: "3.0.2")],
                      targets: [.target(name: "PusherChatkit",
                                        dependencies: ["PusherPlatform",
                                                       "PushNotifications"],
                                        path: "Chatkit"),],
                      swiftLanguageVersions: [.v4,
                                              .v4_2,
                                              .v5])
