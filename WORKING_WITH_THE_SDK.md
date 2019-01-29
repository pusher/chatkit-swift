# Working with the SDK

## Dependencies

### Overview

We use [Carthage](https://github.com/Carthage/Carthage#installing-carthage) to manage the SDK's dependencies. The dependencies that the SDK requires to function are defined in the [`Cartfile`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile).

At the time of writing the dependencies are:

* [`pusher-platform-swift`](https://github.com/pusher/pusher-platform-swift): this is a low(er) level SDK that is shared by all Pusher SDKs that interact with products running on the shared Pusher platform.
* [`beams-chatkit-swift`](https://github.com/pusher/beams-chatkit-swift): this is a Chatkit-only "fork" of the [Beams Swift SDK](https://github.com/pusher/push-notifications-swift). Once it's possible to we should be using the [Beams Swift SDK](https://github.com/pusher/push-notifications-swift) instead of the Chatkit fork.

Any dependencies that are only required for testing are defined in [`Cartfile.private`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile.private).

At the time of writing the test-only dependencies are:

* [`CryptoSwift`](https://www.github.com/krzyzanowskim/CryptoSwift): a crypto library used as part of generating tokens for making requests in tests.
* [`hamchapman/Mockingjay`](https://github.com/hamchapman/Mockingjay): this is a fork of [`kylef/Mockingjay`](https://github.com/kylef/Mockingjay). It is an HTTP stubbing library that we forked to add support for stubbing subscriptions.

All of these dependencies have their versions locked in the [`Cartfile.resolved` file](https://github.com/pusher/chatkit-swift/blob/master/Cartfile.resolved).

### Fetching and managing dependencies

To make sure you have the appropriate dependencies for developing locally you need to run:

```
carthage bootstrap
```

If you want to update one of the dependencies then make the desired change in the [`Cartfile`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile) or [`Cartfile.private`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile.private) and then run:

```
carthage update INSERT_DEPENDENCY_NAME_HERE
```

for example

```
carthage update pusher-platform-swift
```

If you want to update all dependencies then you can run `carthage update` on its own.

### Keeping dependencies in sync between Cartfile and PusherChatkit.podspec

Whenever you make a change to a dependency in one of the [`Cartfile`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile) or [PusherChatkit.podspec](https://github.com/pusher/chatkit-swift/blob/master/PusherChatkit.podspec) you must ensure that the change is reflected in the other.

### Platform-specific dependencies

Most dependencies will be used for all platforms that the SDK targets: iOS, macOS, tvOS, and watchOS. However, there are times when you only want a dependency to be included for certain platforms.

The `beams-chatkit-swift` dependency is one such dependency. We only want it to be included for iOS and macOS.

Specifying this in the podspec is [simple enough](https://github.com/pusher/chatkit-swift/blob/3f6bd93a5939480a99b1811cf0a3764c323b5b4b/PusherChatkit.podspec#L15-L16).

However, making this work with Carthage is a bit more involved.

If you look in the [project file](https://github.com/pusher/chatkit-swift/blob/master/PusherChatkit.xcodeproj/project.pbxproj) and search for `Copy Carthage Frameworks` you can find a `shellScript` value that is a beautifully formatted script to handle copying only the relevant frameworks into the build, depending on the platform that's being built for.

This only applies for the test target (`PusherChatkitTests`). For the framework target (`PusherChatkit`) there isn't such a script because all that's required is a [special config](https://github.com/pusher/chatkit-swift/blob/master/Carthage.xcconfig) that sets custom `FRAMEWORK_SEARCH_PATHS` values to ensure that the frameworks for the required dependencies can be discovered.

### Developing in conjucation with pusher-platform-swift

Sometimes you'll like want to do some development alongside some updates to [pusher-platform-swift](https://github.com/pusher/pusher-platform-swift). The simplest way to get this working locally (or even generally) is to change the `Cartfile` to point to a different source for the SDK. So, for example, you could change `github "pusher/pusher-platform-swift" ~> 0.6` in the [`Cartfile`](https://github.com/pusher/chatkit-swift/blob/master/Cartfile) to instead be `github "pusher/pusher-platform-swift" "testing-branch"` and then after running `carthage update pusher-platform-swift` you'd then be using the `testing-branch` of `pusher-platform-swift` as a dependency.

Equally, if you don't want to push changes up to GitHub then you can use a local version of `pusher-platform-swift`. An example of how to do so is left as a comment in the `Cartfile`. You'll essentially want something in the form of: `git "file:///Users/ham/pusher/pusher-platform-swift" "branch-name"` and then again, running `carthage update pusher-platform-swift` will update your dependency to your local version of `pusher-platform-swift` using the `branch-name` branch.

This can be quite a slow feedback loop though as Carthage involves rebuilding the framework.

As such, sometimes it's quickest to instead run `cat ./Sources/**/*.swift > pusher-platform.swift` in the `pusher-platform-swift` repo and then add the resulting `pusher-platform.swift` file into your `chatkit-swift` SDK project.

The Chatkit SDK will then use the code from `pusher-platform.swift` as opposed to the dependency framework, even if you don't remove the dependency from the Chatkit SDK. This is a nice, quick way to iterate on changes to `pusher-platform-swift` when they relate to Chatkit. Just don't forget to then remove the file and copy over any of the changes you made to the `pusher-platform-swift` related code back into the `pusher-platform-swift` repo!

## Debugging issues

### Memory leaks

If you suspect a memory leak then you should run the tests or the example app having configured some code diagnostics in the appropriate scheme's Run action. You'll want to enable the `Malloc stack` option (Live Allocations Only is fine). Then run the tests / app as normal and when you want to inspect the memory graph you can enable the memory graph debugger. More information about using it can be found online, but [here](https://useyourloaf.com/blog/xcode-visual-memory-debugger/) is a simple introduction to it. Some Apple-provide docs for it can be found [here](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/debugging_with_xcode/chapters/special_debugging_workflows.html#//apple_ref/doc/uid/TP40015022-CH9-DontLinkElementID_1).

### Race conditions

If you suspect a race condition somewhere then it could be that you've not appropriately synchronised access to some data. The SDK includes `PCSynchronizedArray` and `PCSynchronizedDictionary` primitives, which should help you in most cases. If you want to debug an issue then you can enable the Thread Sanitizer and run the tests or the example app and it should help reveal where you've got some thread-related issues. More information about enabling the Thread Sanitizer can be found [here](https://developer.apple.com/documentation/code_diagnostics/thread_sanitizer/enabling_the_thread_sanitizer).

## Misc

### project.pbxproj git conflicts

This only really happens when you've made build related changes in multiple places and git doesn't know how to resolve the conflict. A build related change includes adding new files to the project.

You can usually pretty easily resolve these conflicts by ensuring the correct set of files are referenced for the commit that you're working with. If you're unsure then the best thing is to remove all of the conflict and then go into Xcode and right-click on the relevant directory in the sidebar and click `Add files to PusherChatkit...` and then select the files to add in that are appropriate for your commit.

### It's not working and I don't know why

Things to try, in increasing order of desperation:

* Clean your build (⌘+k) and try again
* Restart Xcode
* If related to a dependency, `rm -rf ./Carthage && carthage bootstrap`
* Close Xcode, remove all contents from DerivedData `rm -rf ~/Library/Developer/Xcode/DerivedData`, reopen Xcode
