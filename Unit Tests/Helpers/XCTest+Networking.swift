import XCTest
import Mockingjay
import PusherPlatform
@testable import PusherChatkit

// MARK: - Networking

internal extension XCTest {
    
    struct Networking {
        
        // MARK: - Properties
        
        static let testInstanceLocator = "test:instance:locator"
        static let testUserIdentifier = "testUserIdentifier"
        
        // MARK: - Paths
        
        enum Path: String {
            
            case users
            
        }
        
    }
    
}

// MARK: - Mockingjay

internal extension XCTest {
    
    // MARK: - Properties
    
    private static let instanceLocatorSeparator: Character = ":"
    
    // MARK: - Internal methods
    
    @discardableResult func stubSubscription(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path, with jsonFilename: String) -> Mockingjay.Stub? {
        guard let uri = uri(of: service, version: version, instanceLocator: instanceLocator, path: path),
            let stubURL = Bundle(for: BundleLocator.self).url(forResource: jsonFilename, withExtension: "json"),
            let json = try? String(contentsOf: stubURL).replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: ""),
            let data = "[1, \"\", {}, \(json)]\n".data(using: .utf8) else {
                return nil
        }
        
        return stub(Mockingjay.uri(uri), jsonData(data))
    }
    
    @discardableResult func stubSubscription(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path, with status: Int) -> Mockingjay.Stub? {
        guard let uri = uri(of: service, version: version, instanceLocator: instanceLocator, path: path) else {
            return nil
        }
        
        return stub(Mockingjay.uri(uri), http(status))
    }
    
    // MARK: - Private methods
    
    private func uri(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path) -> String? {
        let instanceLocatorComponents = instanceLocator.split(separator: XCTest.instanceLocatorSeparator)
        
        guard instanceLocatorComponents.count == 3,
            let identifier = instanceLocatorComponents.last,
            let host = try? PPBaseClient.host(for: instanceLocator) else {
                return nil
        }
        
        return "https://\(host)/services/\(service.rawValue)/\(version.rawValue)/\(identifier)/\(path)"
    }
    
}

func jsonFile(named name: String) -> (URLRequest) -> Mockingjay.Response {
    let bundle = Bundle(for: BundleLocator.self)
    
    guard let url = bundle.url(forResource: name, withExtension: "json"),
        let data = try? Data(contentsOf: url) else {
            fatalError("Failed to locate JSON fixture.")
    }
    
    return jsonData(data)
}

// MARK: - Bundle locator

private class BundleLocator {}
