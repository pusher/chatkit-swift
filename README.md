# Chatkit Retirement Announcement
We are sorry to say that as of April 23 2020, we will be fully retiring our
Chatkit product. We understand that this will be disappointing to customers who
have come to rely on the service, and are very sorry for the disruption that
this will cause for them. Our sales and customer support teams are available at
this time to handle enquiries and will support existing Chatkit customers as
far as they can with transition. All Chatkit billing has now ceased , and
customers will pay no more up to or beyond their usage for the remainder of the
service. You can read more about our decision to retire Chatkit here:
[https://blog.pusher.com/narrowing-our-product-focus](https://blog.pusher.com/narrowing-our-product-focus).
If you are interested in learning about how you can build chat with Pusher
Channels, check out our tutorials.

# PusherChatkit (chatkit-swift)

[![Build Status](https://app.bitrise.io/app/b991488f69c6c503/status.svg?token=k8uHB_7_HNRSCzlVcghexg&branch=master)](https://app.bitrise.io/app/b991488f69c6c503)
[![Read the docs](https://img.shields.io/badge/read_the-docs-92A8D1.svg)](https://docs.pusher.com/chatkit/reference/swift)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![Carthage](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/PusherChatkit.svg)](https://cocoapods.org/pods/PusherChatkit)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/pusher/chatkit-swift/blob/master/LICENSE.md)

Find out more about Chatkit [here](https://pusher.com/chatkit).

## Building and Running

### Minimum Requirements

* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835) - The easiest way to get Xcode is from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12), but you can also download it from [developer.apple.com](https://developer.apple.com/) if you have an AppleID registered with an Apple Developer account.

* Swift version 4.1 and above

* iOS version 10.0

Before building & running in Xcode, install all of the required dependencies with [Carthage](https://github.com/pusher/chatkit-tutorial-ios#carthage) or [CocoaPods](https://github.com/pusher/chatkit-tutorial-ios#cocoapods).

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Chatkit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target '<Your Target Name>' do
  pod 'PusherChatkit'
end
```

Then, run the following command:

```bash
$ pod install
```

> You might need to use the `--repo-update` flag to ensure the specs repository is aware of the latest version of PusherChatkit.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Chatkit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/chatkit-swift"
```

Run `carthage update` to build the framework and drag the built `PusherChatkit.framework`, `PusherPlatform.framework` and `PushNotifications.framework` into your Xcode project.

## Deprecated versions

 Versions of the library below
 [1.0.0](https://github.com/pusher/chatkit-swift/releases/tag/1.0.0) are
 deprecated and support for them will soon be dropped.

 It is highly recommended that you upgrade to the latest version if you're on
 an older version. To view a list of changes, please refer to the
 [CHANGELOG](CHANGELOG.md).

## Getting started

Head over to [our documentation](https://docs.pusher.com/chatkit/reference/swift).

## Running tests

Some of the tests require a valid Chatkit instance locator, key, and token provider URL.

To set this up, run the following command:

```bash
cp Tests/Config/TestConfigExample.swift Tests/Config/TestConfig.swift
```

Then edit `Tests/Config/TestConfig.swift` to include a valid Chatkit instance locator, key, and token provider URL.

## Communication

- Found a bug? Please open an [issue](https://github.com/pusher/chatkit-swift/issues).
- Have a feature request. Please open an [issue](https://github.com/pusher/chatkit-swift/issues).
- If you want to contribute, please submit a [pull request](https://github.com/pusher/chatkit-swift/pulls) (preferrably with some tests 🙂 ).

## Credits

PusherChatkit is owned and maintained by [Pusher](https://pusher.com).

## License

PusherChatkit is released under the MIT license. See [LICENSE](https://github.com/pusher/chatkit-swift/blob/master/LICENSE.md) for details.
