# PusherChat (pusher-chat-api-swift)

[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/pusher/pusher-chat-api-swift/master/LICENSE.md)


## I just want to get started

Head over to [our documentation](https://pusher-mimir.herokuapp.com/chat-api/reference/swift/).


## Table of Contents

* [Installation](#installation)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
  * [Directly using a Framework](#directly-using-a-framework)
* [Using the SDK](#using-the-sdk)
* [Testing](#testing)
* [Communication](#communication)
* [Credits](#credits)
* [License](#license)


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects and is our recommended method of installing PusherChat and its dependencies.

If you don't already have the Cocoapods gem installed, run the following command:

```bash
$ gem install cocoapods
```

Then run `pod init` to create your `Podfile` (if you don't already have one), and add the following lines to it:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0' # change this if you're not making an iOS app!

target 'your-app-name' do
  pod 'PusherChat'
end

# the rest of the file...
```

Then, run the following command:

```bash
$ pod install
```

If you find that you're not having the most recent version installed when you run `pod install` then try running:

```bash
$ pod repo update
$ pod install
```

Also you'll need to make sure that you've not got the version of PusherChat locked to an old version in your `Podfile.lock` file.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PusherChat into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/pusher-chat-api-swift"
```

### Directly using a framework

```
TODO
```

## Using the SDK

For information about how to use the SDK please see [our documentation](https://pusher-mimir.herokuapp.com/chat-api/reference/swift/).


## Testing

There are a set of tests for the library that can be run using the standard method (Command-U in Xcode).

The tests also get run on [Travis-CI](https://travis-ci.org/pusher/pusher-chat-api-swift). See [.travis.yml](https://github.com/pusher/pusher-chat-api-swift/blob/master/.travis.yml) for details on how the Travis tests are run.


## Communication

- Found a bug? Please open an issue.
- Have a feature request. Please open an issue.
- If you want to contribute, please submit a pull request (preferrably with some tests 🙂 ).


## Credits

PusherChat is owned and maintained by [Pusher](https://pusher.com). It was originally created by [Hamilton Chapman](https://github.com/hamchapman).


## License

PusherChat is released under the MIT license. See [LICENSE](https://github.com/pusher/pusher-chat-api-swift/blob/master/LICENSE.md) for details.
