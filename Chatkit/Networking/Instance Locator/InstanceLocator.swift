import struct PusherPlatform.InstanceLocator

protocol HasInstanceLocator {
    var instanceLocator: InstanceLocator { get }
}

protocol InstanceLocator {
    var region: String { get }
    var identifier: String { get }
    var version: String { get }
}

extension PusherPlatform.InstanceLocator: InstanceLocator {}
