# Releasing PusherChatkit

## General things to consider

* If you've updated a dependency in one of `Cartfile` or `PusherChatkit.podspec` then make sure it is reflected in the other.

## Prerequisites

* [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
* [Cocoapods](https://guides.cocoapods.org/using/getting-started.html#installation)

## Checklist

1. Update [`CHANGELOG.md`](https://github.com/pusher/chatkit-swift/blob/master/CHANGELOG.md), following the existing format.
2. Update version string in:
  i. [`Tests/ChatManagerTests.swift`](https://github.com/pusher/chatkit-swift/blob/master/Tests/ChatManagerTests.swift)
  ii. [`Sources/ChatManager.swift`](https://github.com/pusher/chatkit-swift/blob/master/Sources/ChatManager.swift)
  iii. [`Sources/Info.plist`](https://github.com/pusher/chatkit-swift/blob/master/Sources/Info.plist)
  iv. [`Tests/Supporting Files/Info.plist`](https://github.com/pusher/chatkit-swift/blob/master/Tests/Supporting%20Files/Info.plist)
3. Run `carthage build --no-skip-current` to ensure that the framework builds. This will likely take a while - go get a drink.
4. In Xcode, run the tests (⌘+u) with the `PusherChatkit` target selected (the briefcase symbol in the top bar) for an iOS device, your Mac, and a tvOS device.
5. Commit all of the version changes: `git commit -am "Bump to NEW_VERSION_NUMBER"`
6. Tag the commit with the version number: `git tag -a NEW_VERSION_NUMBER -m NEW_VERSION_NUMBER`
7. Push the commit and the tags: `git push origin master && git push --tags`

_[Skip 8 and 9 if you have already registed with Cocoapods trunk on your machine]_

8. Register your machine with Cocoapods by running `pod trunk register support@pusher.com`
9. Go to Zendesk (or ask someone with access) to click the link in the challenge email that will have been sent to support@pusher.com. Note that it quite often ends up in the "spam" section of Zendesk so make sure you check there too.
10. Push the new version to Cocoapods: `pod trunk push PusherChatkit.podspec` (you can add `--allow-warnings` if there are build-related warnings that are safe to ignore). You might also need to add `--swift-version=4` (or another Swift version) depending on how you've got things set up locally.
11. Add a message to the #chatkit-release channel in the community Slack to notify people of the new release.
