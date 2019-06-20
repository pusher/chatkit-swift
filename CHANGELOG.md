# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/chatkit-swift/compare/1.5.2...HEAD)

### Fixed

- Remove unnecessary async operations (internal ones)
- Don't allow references to newly deserialised entities to escape once their
  details have been merged in to the canonical copies of the entity.

## [1.5.2](https://github.com/pusher/chatkit-swift/compare/1.5.1...1.5.2) - 2019-06-11

## Fixed

- Potential memory corruptions in PCSynchronizedArrays

## [1.5.1](https://github.com/pusher/chatkit-swift/compare/1.5.0...1.5.1) - 2019-05-28

## Fixed

- Updated dependency Pusher Beams to the latest version (2.0.2).

## [1.5.0](https://github.com/pusher/chatkit-swift/compare/1.4.4...1.5.0) - 2019-04-24

## Added

- `unreadCount` and `lastMessageAt` properties added to rooms. These reflect values
  of unread messages and when the last message was sent at in the room.

## [1.4.4](https://github.com/pusher/chatkit-swift/compare/1.4.3...1.4.4) - 2019-04-01

## Fixed

- Refresh URL's were incorrectly being constructed.

## [1.4.3](https://github.com/pusher/chatkit-swift/compare/1.4.2...1.4.3) - 2019-03-20

## Fixed

- PCMultipartAttachmentPayload.url is now public.

## [1.4.2](https://github.com/pusher/chatkit-swift/compare/1.4.1...1.4.2) - 2019-03-20

## Fixed

- Publicly exposed Multipart structs were previously using the `internal` access modifier
  by default. This has now been changed to `public`.

## [1.4.1](https://github.com/pusher/chatkit-swift/compare/1.4.0...1.4.1) - 2019-03-12

## Fixed

- Added public initialiser to `PCPartUrlRequest`

## [1.4.0](https://github.com/pusher/chatkit-swift/compare/1.3.1...1.4.0) - 2019-03-08

## Added

- Multipart messaging support:
 - `sendMultipartMessage`, `sendSimpleMessage`, `subscribeToRoomMultipart` and `fetchMultipartMessages` methods.
 - `onMultipartMessage` delegate method.

## Deprecated

- `sendMessage`, `subscribeToRoom` and `fetchMessagesFromRoom` are deprecated in favour of
  their multipart counterparts. They will be removed in a future major release of the SDK.

## [1.3.1](https://github.com/pusher/chatkit-swift/compare/1.3.0...1.3.1) - 2019-03-05

### Fixed

- `PCSynchronizedDictionary` uses a serial queue. Previously setting values would happen
  ansynchronously without any barriers which could give us a wrong result. For sake of
  simplicity, the queue has been made serial with sync operations.

## [1.3.0](https://github.com/pusher/chatkit-swift/compare/1.2.3...1.3.0) - 2019-01-25

### Added

- You can call `unsubscribe()` on a `PCRoom` to unsubscribe from it
- `onNewReadCursor` has been added to the `PCChatManagerDelegate`, which allows you to get notified of read cursor updates for the current user. Note that to support existing users of the read cursor functionality, `onNewReadCursor` on the `PCRoomDelegate` will also still be called for new read cursors for the current user. This functionality will be removed in a future release that contains other breaking changes (i.e. 2.0.0, in all likelihood)

### Fixed

- Appropriate `PCChatManagerDelegate` and `PCRoomDelegate` hooks will be called upon reconnection when state has changed during the period of disconnection
- `createdAtDate`, `updatedAtDate`, and `deletedAtDate` should no longer lead to crashes
- Only call `PCRoomDelegate` functions once a room subscription has been fully established
- Removed some race conditions
- Fixed some reference cycles

### Removed

- `PCRoomDelegate` no longer has a restriction to ensure that conforming types also conform to `NSObjectProtocol`

## [1.2.3](https://github.com/pusher/chatkit-swift/compare/1.2.2...1.2.3) - 2018-12-21

### Fixed

- Push notifications now work regardless of when `registerForRemoteNotifications` is called

## [1.2.2](https://github.com/pusher/chatkit-swift/compare/1.2.1...1.2.2) - 2018-12-19

### Fixed

- Push notifications now work if `registerDeviceToken` is called before successfully connecting to Chatkit

## [1.2.1](https://github.com/pusher/chatkit-swift/compare/1.2.0...1.2.1) - 2018-11-30

### Added

- `deletedAt` and `deletedAtDate` properties on `PCRoom`

## [1.2.0](https://github.com/pusher/chatkit-swift/compare/1.1.0...1.2.0) - 2018-11-30

### Added

- Support for Push Notifications

## [1.1.0](https://github.com/pusher/chatkit-swift/compare/1.0.0...1.1.0) - 2018-11-29

### Added

- Rooms now support `customData`
- Message attachments now have a `name` property

### Removed

- `deletedAt` on `PCRoom` has been removed. It was never set so was never useful

## [1.0.0](https://github.com/pusher/chatkit-swift/compare/0.10.3...1.0.0) - 2018-10-29

### Changed

#### Breaking

- All `PCChatManagerDelegate` and `PCRoomDelegate` functions are now prefixed with `on`, e.g. `userJoined` has become `onUserJoined`
- `PCRoomDelegate`'s `newMessage` function has had the `new` prefix removed to make it clearer that it is the function that gets called when a new message is received over the room subscription (including historical messages), so in conjunction with the change above it is now `onMessage`
- All mentions (mainly relevant to function parameter names) of anything that was previously `Id` is now `ID`, e.g. `roomId` is now `roomID`
- `sendMessage` parameter `attachmentType` renamed to `attachment`
- The ordering of messages returned by `fetchMessagesFromRoom` is now from oldest to newest
- Room members are only populated once you have subscribed to a room
- Message attachments no longer have the `fetchRequired` property because you can no always directly use an attachment's link
- `startedTypingIn` and `stoppedTypingIn` have both been removed. Use `typing(in: ...)` instead
- Room IDs are now represented using `String`s instead of `Int`s

### Removed

- `lastSeenAt` is no longer available on `PCUser` objects
- `fetchAttachment` as it's no longer required (you can use the attachment's link directly)
- `userCameOnline` and `userWentOffline` (replaced by `onPresenceChanged`)

### Added

- `onPresenceChanged` (replacing `userCameOnline` and `userWentOffline`)

## [0.10.3](https://github.com/pusher/chatkit-swift/compare/0.10.2...0.10.3) - 2018-09-10

### Fixed

- No longer crashes if disconnect is called midway through a successful connection process

### Changed

- Bump PusherPlatform dependency to 0.6.2

## [0.10.2](https://github.com/pusher/chatkit-swift/compare/0.10.1...0.10.2) - 2018-08-22

### Added

- A retry strategy can now be provided to `PCTokenProvider` as part of its `init`

## [0.10.1](https://github.com/pusher/chatkit-swift/compare/0.10.0...0.10.1) - 2018-08-21

### Fixed

- Fixed potential crash upon reconnection

### Changed

- Bump PusherPlatform dependency to 0.6.1

## [0.10.0](https://github.com/pusher/chatkit-swift/compare/0.9.0...0.10.0) - 2018-08-09

### Changed

- `subscribeToRoom` now has a (required) completion handler of type `PCErrorCompletionHandler`

### Added

- There is now a version of `subscribeToRoom` that takes a `roomID` in place of a `PCRoom`

## [0.9.0](https://github.com/pusher/chatkit-swift/compare/0.8.4...0.9.0) - 2018-06-14

### Changed

- `sendMessage` now requires a value for the `text` parameter
- All `PCMessage`s must have a `text` property

## [0.8.4](https://github.com/pusher/chatkit-swift/compare/0.8.3...0.8.4) - 2018-05-26

### Fixed

- Ensure that `fetchMessagesFromRoom` calls completion handler even if no messages were fetched

## [0.8.3](https://github.com/pusher/chatkit-swift/compare/0.8.2...0.8.3) - 2018-05-25

### Fixed

- Ensure that `fetchMessagesFromRoom` returns the correct number of messages

## [0.8.2](https://github.com/pusher/chatkit-swift/compare/0.8.1...0.8.2) - 2018-05-04

### Changed

- Requests resulting from `setReadCursor` are batched up if made in quick succession
- File upload path has been updated to include the user ID

## [0.8.1](https://github.com/pusher/chatkit-swift/compare/0.8.0...0.8.1) - 2018-04-24

### Fixed

- Fixed memory leak caused by delegates not having only weak references taken

PR: [#77](https://github.com/pusher/chatkit-swift/pull/77)
Authored by: [@steve228uk](https://github.com/steve228uk)

## [0.8.0](https://github.com/pusher/chatkit-swift/compare/0.7.2...0.8.0) - 2018-04-19

### Changed

- Bump PusherPlatform dependency to 0.5.0

## [0.7.2](https://github.com/pusher/chatkit-swift/compare/0.7.1...0.7.2) - 2018-04-16

### Fixed

- Fixed typing events not being delivered properly [#72](https://github.com/pusher/chatkit-swift/issues/72)
- Fixed warnings in example app

## [0.7.1](https://github.com/pusher/chatkit-swift/compare/0.7.0...0.7.1) - 2018-04-16

### Fixed

- Fixed `sendMessage` not working if no `attachment` was provided [@steve228uk](https://github.com/steve228uk)
- `leaveRoom` no longer recursively calls itself [#74](https://github.com/pusher/chatkit-swift/issues/74)

## [0.7.0](https://github.com/pusher/chatkit-swift/compare/0.6.4...0.7.0) - 2018-03-26

### Added

- `PCBaseClient` added as a `typealias` for `PPBaseClient`

### Changed

- `subscribeToRoom` will attempt to join the `PCCurrentUser` to the room if the user is not already a member
- `PCRoom` no longer stores the cursors that relate to it; they are now all accessed using the `readCursor` function on `PCCurrentUser`, and the return type of this is `PCCursor?` (an optional `PCCursor`)
- `PCCurrentUser`'s `setCursor` function has been renamed to `setReadCursor`
- `cursorSet` renamed to `newCursor` in `PCRoomDelegate`
- Bump PusherPlatform dependency to 0.4.2
- `fetchToken` calls to `PCTokenProvider` are queued if there's an existing request underway

### Removed

- `ChatManager` no longer stores a reference to the `users` list, nor the `userSubscription`
- `PCBasicCursorState` has been removed so now if you try to access the read cursors for a given `userId`-`roomId` combination you will either receive a `PCCursor` or `nil`
- `currentUserCursor` has been removed from `PCRoom`; again, you'll instead need to use the `readCursor` function on `PCCurrentUser`
- `getAllRooms` has been removed
- `getJoinedRooms` has been removed

## [0.6.4](https://github.com/pusher/chatkit-swift/compare/0.6.3...0.6.4) - 2018-03-01

### Changed

- Bump PusherPlatform dependency to 0.4.1

### Fixed

- Test target now works as expected

## [0.6.3](https://github.com/pusher/chatkit-swift/compare/0.6.2...0.6.3) - 2018-02-26

### Changed

- Use different underlying PusherPlatform `Instance` to connect to presence service

## [0.6.2](https://github.com/pusher/chatkit-swift/compare/0.6.1...0.6.2) - 2018-02-26

### Fixed

- Ensure connection completion handlers get called even if the connecting user is not a member of any rooms

## [0.6.1](https://github.com/pusher/chatkit-swift/compare/0.6.0...0.6.1) - 2018-02-26

### Changed

- Bump PusherPlatform dependency to 0.4.0

### Added

- Provide SDK info to PusherPlatform's `Instance`s to add SDK info headers to requests

## [0.6.0](https://github.com/pusher/chatkit-swift/compare/0.5.0...0.6.0) - 2018-02-16

### Changed

- `ChatManager` requires a `userId` be provided when it is instantiated
- `PCTokenProvider` no longer takes a `userId` parameter when it is instantiated
- The completion handler passed to `connect` of `ChatManager` will now only be called once the following has completed, either successfully or unsuccessfully:
    * User subscription has been established
    * Presence subscription has been established
    * Initial cursors fetch has completed (getting initial values for read cursors of the current user for the rooms that they are a member of)
    * Initial users fetch has completed (getting initial information about user IDs that were seen in the list of members of the rooms that the current user is a member of)
- Bumped PusherPlatform dependency to 0.3.1

### Added

- Support for read cursors:
    * `setCursor` added to `PCCurrentUser`, usage of which looks like:

    ```swift
    currentUser.setCursor(position: 123, roomId: myRoom.id) { error in
        guard error == nil else {
            print("Error setting cursor: \(error!.localizedDescription)")
            return
        }
        print("Succeeded in setting cursor")
    }
    ```
    * `cursorSet` function added to `PCRoomDelegate` so that you can be notified of other members in the room updating their read cursors; the function looks like:

    ```swift
    func cursorSet(cursor: PCCursor) {
        print("Cursor set for \(cursor.user.displayName) at position \(cursor.position)")
    }
    ```

## [0.5.0](https://github.com/pusher/chatkit-swift/compare/0.4.3...0.5.0) - 2018-01-26

### Changed
- Bump PusherPlatform dependency to 0.3.0
- `addMessage` on `PCCurrentUser` has been deprecated
- `text` property on `PCMessage` is now optional, i.e. `String?`

### Added
- Support for message attachments
- `sendMessage` on `PCCurrentUser`, which replaces the now deprecated `addMessage`; usage looks like this:

```swift
currentUser.sendMessage(
    roomId: roomId,
    text: "My message text"
) { messageId, err in
    guard err == nil else {
        print("Error sending message \(err!.localizedDescription)")
        return
    }
    print("Successfully sent message with ID: \(messageId!)")
}
```

Note that the room's ID is now required as a parameter, not the whole `PCRoom` object as was the case with `addMessage`

- `sendMessage` supports sending messages with an attachment; this looks like:

```swift
let imageName = Bundle.main.path(forResource: "dog", ofType: "jpg")
let imageURL = URL(fileURLWithPath: imageName!)

currentUser.sendMessage(
    roomId: roomId,
    text: "My message text",
    attachmentType: .fileURL(imageURL, name: "dog.jpg")
) { messageId, err in
    guard err == nil else {
        print("Error sending message \(err!.localizedDescription)")
        return
    }
    print("Successfully sent message with ID: \(messageId!)")
}
```

There are currently 3 different `attachmentTypes` supported, as described in the `PCAttachmentType` enum:

* `.fileData(_: Data, name: String)`: Use this if you have your file as `Data`. The `name` parameter is the name that the file will be given when it is stored by our servers.
* `.fileURL(_: URL, name: String)`: Use this if you have your file as `Data`. The `name` parameter is the name that the file will be given when it is stored by our servers.
* `.link(_: String, type: String)`: Use this if you have a file stored elsewhere that you would like to attach to a message without it being uploaded to and stored by the Chatkit servers. The `type` `parameter` currently needs to be one of `"image"`, `"video"`, `"audio"`, or `"file"`. This will likely eventually be encoded in an `enum` but for now we're leaving it as just a `String` while we finalise the API.

Here's an example of using the `.link(_: String, type: String)` attachment type:

```swift
currentUser.sendMessage(
    roomId: roomId,
    text: "My message text",
    attachmentType: .link("https://i.giphy.com/RpByGPT5VlZiE.gif", type: "image")
) { messageId, err in
    guard err == nil else {
        print("Error sending message \(err!.localizedDescription)")
        return
    }
    print("Successfully sent message with ID: \(messageId!)")
}
```
- `PCMessage`s now have an optional `attachment` property of type `PCAttachment?`. `PCAttachment` looks like this:

```swift
public struct PCAttachment {
    public let fetchRequired: Bool
    public let link: String
    public let type: String
}
```

If `fetchRequired` is `true` then it means that the attachment is stored on the Chatkit servers and you need to make a request to the Chatkit API to fetch a valid link. To do this you can use the `fetchAttachment` function that has been added to the `PCCurrentUser` class. You use that like this:

```swift
currentUser.fetchAttachment(attachmentLink) { fetchedAttachment, err in
    guard err == nil else {
        print("Error fetching attachment \(err!.localizedDescription)")
        return
    }

    print("Fetched attachment link: \(fetchedAttachment!.link)")
}
```

You can then use the `fetchedAttachment.link` to download the file, if you so wish.

- `downloadAttachment` function added to `PCCurrentUser` to make downloading Chatkit-stored attachments easier. Once you've got the `link` from a `PCFetchedAttachment` you can either use your own download mechanism of choice or you can use the `downloadAttachment` function. Usage of it looks like this:

```swift
currentUser.downloadAttachment(
    fetchedAttachment.link,
    to: myChosenDestination,
    onSuccess: { url in
        print("Downloaded successfully to \(url.absoluteString)")
    },
    onError: { error in
        print("Failed to download attachment \(error.localizedDescription)")
    },
    progressHandler: { bytesReceived, totalBytesToReceive in
        print("Download progress: \(bytesReceived) / \(totalBytesToReceive)")
    }
)
```

Here `myChosenDestination` is an object of type `PCDownloadFileDestination`. This is a type based on [Alamofire's `DownloadFileDestination`](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#download-file-destination). It lets you specify where you'd like to have the download stored (upon completion).

One option for creating a `PCDownloadFileDestination` is to use the `PCSuggestedDownloadDestination` function, which is again based on an Alamofire construct: `DownloadRequest.suggestedDownloadDestination`. You can provide it a `PPDownloadOptions` object which determines whether or not the process of moving the downloaded file to the specified destination should be allowed to remove any existing files at the same path and if it should be able to create any required intermediate directories. This is expressed as an `OptionSet` with the following options:

* `.createIntermediateDirectories`
* `.removePreviousFile`

- Typealiases for useful PusherPlatform types, specifically:

```swift
public typealias PCHTTPTokenProvider = PPHTTPEndpointTokenProvider
public typealias PCTokenProviderRequest = PPHTTPEndpointTokenProviderRequest
public typealias PCLogger = PPLogger
public typealias PCLogLevel = PPLogLevel
public typealias PCDefaultLogger = PPDefaultLogger
public typealias PCDownloadFileDestination = PPDownloadFileDestination
public typealias PCDownloadOptions = PPDownloadOptions
public typealias PCRetryStrategy = PPRetryStrategy
public typealias PCDefaultRetryStrategy = PPDefaultRetryStrategy

public func PCSuggestedDownloadDestination(...) { return PPSuggestedDownloadDestination(...) }
```

This means that importing PusherPlatform should never need to be done anymore.

- `PCMessage` conforms to `CustomDebugStringConvertible`
- Added `Date` versions of timestamp properties on: `PCCurrentUser`, `PCUser`, `PCRoom`, and `PCMessage`. For example, if you want a `Date` version of the `createdAt` property of a `PCMessage` you can now call `.createdAtDate` on the relevant `PCMessage` to get a `Date`. Thanks [@nitrag](https://github.com/nitrag) for the suggestion.

## [0.4.3](https://github.com/pusher/chatkit-swift/compare/0.4.2...0.4.3) - 2018-01-09

### Added
- `ChatManager` has had a `disconnect` function added to it so that you can disconnect from Chatkit.

## [0.4.2](https://github.com/pusher/chatkit-swift/compare/0.4.1...0.4.2) - 2018-01-06

### Fixed
- Correctly access `user_id` in `PCUserSubscription` for typing indicator events. Thanks [@neoighodaro](https://github.com/neoighodaro)!

## [0.4.1](https://github.com/pusher/chatkit-swift/compare/0.4.0...0.4.1) - 2017-11-01

### Changed
- Bump `PusherPlatform` dependency to 0.2.1

## [0.4.0](https://github.com/pusher/chatkit-swift/compare/0.3.2...0.4.0) - 2017-10-27

### Changed
- `instanceId` parameter renamed to `instanceLocator`

## [0.3.2](https://github.com/pusher/chatkit-swift/compare/0.3.1...0.3.2) - 2017-10-25

### Changed
- Allow `PCTokenProvider` to take a `requestInjector`
- Make `userId` optional when instantiating a `PCTokenProvider`
- Bump `PusherPlatform` dependency to 0.1.32

## [0.3.1](https://github.com/pusher/chatkit-swift/compare/0.3.0...0.3.1) - 2017-09-21

### Added
- Swift 4 support

## [0.3.0](https://github.com/pusher/chatkit-swift/compare/0.2.9...0.3.0) - 2017-09-18

### Added
- Danger
- Ability to update a room
- User(s) can be added or removed from the room by providing ids or user objects.
- Improved logging

### Changed
- `PULL_REQUEST_TEMPLATE.md` template
- `PusherChat` -> `PusherChatkit`
- Newly created room will be set to public as default
- `PCTestingTokenProvider` -> `PCTokenProvider`
- `PCTokenProvider` initialization

## [0.2.9](https://github.com/pusher/chatkit-swift/compare/0.2.8...0.2.9) - 2017-08-02

### Changed
- `PCTestingTokenProvider` parameter name
- Move to deneb cluster

## [0.2.8](https://github.com/pusher/chatkit-swift/compare/0.2.7...0.2.8) - 2017-08-01

### Added
- `avatarURL` property in `PCCurrentUser` class
- `isPrivate` property in `PCRoom` class
- Default implementations of `PCRoomDelegate` and `PCChatManagerDelegate` protocol methods

### Changed
- `PCRoomDelegate` delegate methods

## [0.2.7](https://github.com/pusher/chatkit-swift/compare/0.2.6...0.2.7) - 2017-07-28

### Fixed
- Update example code
- Fix path

## [0.2.6](https://github.com/pusher/chatkit-swift/compare/0.2.5...0.2.6) - 2017-07-26

### Changed
- Endpoint from `/users` to `/users_by_ids`

## [0.2.5](https://github.com/pusher/chatkit-swift/compare/0.2.4...0.2.5) - 2017-07-19

### Changed
- Namespace

## [0.2.4](https://github.com/pusher/chatkit-swift/compare/0.2.3...0.2.4) - 2017-07-18

### Changed
- Token provider URL.

## [0.2.3](https://github.com/pusher/chatkit-swift/compare/0.2.2...0.2.3) - 2017-07-17

### Removed
- `eventType`

## [0.2.2](https://github.com/pusher/chatkit-swift/compare/0.2.0...0.2.2) - 2017-06-29

### Added
- Add ability to delete a room
- Add functionality to add a new user to the room

## [0.2.0](https://github.com/pusher/chatkit-swift/compare/0.1.28...0.2.0) - 2017-06-21
