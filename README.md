# PusherChatkit (chatkit-swift)

[![Read the docs](https://img.shields.io/badge/read_the-docs-92A8D1.svg)](https://docs.pusher.com/)
[![Build Status](https://travis-ci.org/pusher/chatkit-swift.svg?branch=master)](https://travis-ci.org/pusher/chatkit-swift)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![Carthage](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/pusher/chatkit-swift/blob/master/LICENSE.md)

## Building and Running

### Minimum Requirements
* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835) - The easiest way to get Xcode is from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12), but you can also download it from [developer.apple.com](https://developer.apple.com/) if you have an AppleID registered with an Apple Developer account.

Before building & running in Xcode, install all of the required dependencies with [Carthage](https://github.com/pusher/chatkit-tutorial-ios#carthage) or [CocoaPods](https://github.com/pusher/chatkit-tutorial-ios#cocoapods).

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods version 1.3.1 or newer is recommended to build Chatkit.

To integrate Chatkit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

# Replace `<Your Target Name>` with your app's target name.
target '<Your Target Name>' do
    pod 'PusherChatkit', '~> 0.2.9'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

> Carthage version 0.25.0 or newer is recommended to build Chatkit.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Chatkit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/chatkit-swift"
```

Run `carthage update` to build the framework and drag the built `PusherChat.framework` and `PusherPlatform.framework` into your Xcode project.

## Getting started

Head over to [our documentation](https://pusher-mimir-staging-pr-78.herokuapp.com/chatkit/reference/swift/).

## Communication

- Found a bug? Please open an [issue](https://github.com/pusher/chatkit-swift/issues).
- Have a feature request. Please open an [issue](https://github.com/pusher/chatkit-swift/issues).
- If you want to contribute, please submit a [pull request](https://github.com/pusher/chatkit-swift/pulls) (preferrably with some tests 🙂 ).


## Credits

PusherChatkit is owned and maintained by [Pusher](https://pusher.com).


## License

PusherChatkit is released under the MIT license. See [LICENSE](https://github.com/pusher/chatkit-swift/blob/master/LICENSE.md) for details.
