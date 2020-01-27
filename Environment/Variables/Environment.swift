import Foundation

public struct Environment {
    
    // MARK: - Properties
    
    public static let instanceLocator: String = Environment.variable(named: "INSTANCE_LOCATOR")
    
}

// MARK: - Value retrieval

extension Environment {
    
    // MARK: - Private methods
    
    private static func variable(named name: String) -> String {
        if let environmentValue = self.environmentVariable(named: name), environmentValue != ProcessInfo.unspecifiedValue {
            return environmentValue
        }
        else if let ciValue = self.ciVariable(named: name), !ciValue.hasPrefix("$(") && !ciValue.hasSuffix(")") {
            return ciValue
        }
        
        preconditionFailure("Please specify the value of the variable in either the enviroment variables section of your current run scheme or inject the value using Swift Variable Injector from Bitrise.")
    }
    
    private static func environmentVariable(named name: String) -> String? {
        return ProcessInfo.processInfo.environment[name]
    }
    
    private static func ciVariable(named name: String) -> String? {
        let mirror = Mirror(reflecting: CI())
        return mirror.children.first { $0.label == name.camelcased(separator: "_") }?.value as? String
    }
    
}
