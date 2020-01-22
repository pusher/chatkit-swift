import Foundation

struct Environment {
    
    // MARK: - Properties
    
    static let instanceLocator: String = Environment.variable(named: "INSTANCE_LOCATOR", ciValue: CI.instanceLocator)
    
    // MARK: - Private methods
    
    private static func variable(named name: String, ciValue: String) -> String {
        guard let value = ProcessInfo.processInfo.environment[name], value != ProcessInfo.unspecifiedValue else {
            assert(!ciValue.hasPrefix("$(") && !ciValue.hasSuffix(")"), "Please specify the value of the variable in either the enviroment variables section of your current run scheme or inject the value using Swift Variable Injector from Bitrise.")
            return ciValue
        }
        
        return value
    }
    
}
