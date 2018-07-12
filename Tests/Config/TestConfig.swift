import Foundation

let testInstanceLocator = "your:instance:locator"
let testInstanceTokenProviderURL = "https://token.provider.url"
let testInstanceKey = "your:key"

let splitInstanceLocator = testInstanceLocator.split(separator: ":")
let splitInstanceKey = testInstanceKey.split(separator: ":")

let testInstanceKeyID = splitInstanceKey.first!
let testInstanceKeySecret = splitInstanceKey.last!
let testInstanceInstanceID = splitInstanceLocator.last!
let testInstanceCluster = splitInstanceLocator[1]
