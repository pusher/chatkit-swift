import Foundation

let testInstanceLocator = "your:instance:locator"
let testInstanceTokenProviderURL = "https://token.provider.url"
let testInstanceKey = "your:key"

let testInstanceKeyID = testInstanceKey.split(separator: ":").first!
let testInstanceKeySecret = testInstanceKey.split(separator: ":").last!
let testInstanceInstanceID = testInstanceLocator.split(separator: ":").last!
let testInstanceCluster = testInstanceLocator.split(separator: ":")[1]
