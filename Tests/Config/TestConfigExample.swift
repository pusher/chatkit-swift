import Foundation

let testInstanceLocator = "your:instance:locator"
let testInstanceKey = "your:key"
let testInstanceTokenProviderURL = "https://token.provider.url"

let splitInstanceLocator = testInstanceLocator.split(separator: ":")
let splitInstanceKey = testInstanceKey.split(separator: ":")

let testInstanceKeyID = splitInstanceKey.first!
let testInstanceKeySecret = splitInstanceKey.last!
let testInstanceInstanceID = splitInstanceLocator.last!
let testInstanceCluster = splitInstanceLocator[1]
