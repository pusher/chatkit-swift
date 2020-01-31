import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

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

// MARK: - Fixtures

func jsonFixture(named name: String) -> HTTPStubsResponse {
    let bundle = Bundle(for: BundleLocator.self)
    
    guard let filePath = bundle.path(forResource: name, ofType: "json") else {
        preconditionFailure("Failed to locate JSON fixture.")
    }
    
    let headers = ["Content-Type" : "application/json"]
    
    return fixture(filePath: filePath, headers: headers)
}

// MARK: - Bundle locator

private class BundleLocator {}
