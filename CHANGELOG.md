# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/chat-api-swift/compare/0.3.2...HEAD)

## [0.3.2](https://github.com/pusher/chat-api-swift/compare/0.3.1...0.3.2) - 2017-10-25
## Changed
- Allow `PCTokenProvider` to take a `requestInjector`
- Make `userId` optional when instantiating a `PCTokenProvider`
- Bump `PusherPlatform` dependency to 0.1.32

## [0.3.1](https://github.com/pusher/chat-api-swift/compare/0.3.0...0.3.1) - 2017-09-21
## Added
- Swift 4 support

## [0.3.0](https://github.com/pusher/chat-api-swift/compare/0.2.9...0.3.0) - 2017-09-18
## Added
- Danger
- Ability to update a room
- User(s) can be added or removed from the room by providing ids or user objects.
- Improved logging

## Changed
- `PULL_REQUEST_TEMPLATE.md` template
- `PusherChat` -> `PusherChatkit`
- Newly created room will be set to public as default
- `PCTestingTokenProvider` -> `PCTokenProvider`
- `PCTokenProvider` initialization

## [0.2.9](https://github.com/pusher/chat-api-swift/compare/0.2.8...0.2.9) - 2017-08-02
## Changed
- `PCTestingTokenProvider` parameter name
- Move to deneb cluster

## [0.2.8](https://github.com/pusher/chat-api-swift/compare/0.2.7...0.2.8) - 2017-08-01
### Added
- `avatarURL` property in `PCCurrentUser` class
- `isPrivate` property in `PCRoom` class
- Default implementations of `PCRoomDelegate` and `PCChatManagerDelegate` protocol methods

## Changed
- `PCRoomDelegate` delegate methods

## [0.2.7](https://github.com/pusher/chat-api-swift/compare/0.2.6...0.2.7) - 2017-07-28
### Fixed
- Update example code
- Fix path

## [0.2.6](https://github.com/pusher/chat-api-swift/compare/0.2.5...0.2.6) - 2017-07-26
### Changed
- Endpoint from `/users` to `/users_by_ids`

## [0.2.5](https://github.com/pusher/chat-api-swift/compare/0.2.4...0.2.5) - 2017-07-19
### Changed
- Namespace

## [0.2.4](https://github.com/pusher/chat-api-swift/compare/0.2.3...0.2.4) - 2017-07-18
### Changed
- Token provider URL.

## [0.2.3](https://github.com/pusher/chat-api-swift/compare/0.2.2...0.2.3) - 2017-07-17
### Removed
- `eventType`

## [0.2.2](https://github.com/pusher/chat-api-swift/compare/0.2.0...0.2.2) - 2017-06-29
### Added
- Add ability to delete a room
- Add functionality to add a new user to the room

## [0.2.0](https://github.com/pusher/chat-api-swift/compare/0.1.28...0.2.0) - 2017-06-21
