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
        else if let repoFileValue = self.repoFile(named: name), repoFileValue != ProcessInfo.unspecifiedValue {
            return repoFileValue
        }
        
        preconditionFailure("Please specify the value of the variable in either i) the enviroment variables section of your current run scheme, or ii) by injecting the value using Swift Variable Injector from Bitrise, or iii) defining it in the dedicated file in the root of the repo.")
    }
    
    private static func environmentVariable(named name: String) -> String? {
        return ProcessInfo.processInfo.environment[name]
    }
    
    private static func ciVariable(named name: String) -> String? {
        let mirror = Mirror(reflecting: CI())
        return mirror.children.first { $0.label == name.hungarianCased(separator: "_") }?.value as? String
    }
    
    private static func repoFile(named name: String) -> String? {
        
        // Load the first line from file `InstanceLocator` thats included in the Environment.framework bundle
        let filename = name.camelcased(separator: "_")

        // We need a *class* to be able to use `Bundle(for:)`.
        // If we ever add a *class* to the `Environment` target then we might potential get rid of this.
        class ForBundleLocation {}
        let environmentBundle = Bundle(for: ForBundleLocation.self)
        
        if let path = environmentBundle.path(forResource: filename, ofType: nil),
            let fileContent = try? String(contentsOfFile: path, encoding: .utf8) {
            
            let lines = fileContent.components(separatedBy: .newlines)
            if lines.count > 0 {
                return lines[0]
            }
        }
        
        return nil
    }
}
