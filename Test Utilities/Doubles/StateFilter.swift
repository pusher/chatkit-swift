import XCTest
@testable import PusherChatkit

public class StubStateFilter: StubBase, StateFilter {
    
    private let hasModifiedSubstate_defaultValueToReturn: Bool
    private let hasCompleteSubstate_defaultValueToReturn: Bool
    private let hasSupportedSignature_defaultValueToReturn: Bool
    
    private let hasModifiedSubstate_valuesToReturn: [VersionedState : Bool]
    private let hasCompleteSubstate_valuesToReturn: [VersionedState : Bool]
    private let hasSupportedSignature_valuesToReturn: [VersionSignature : Bool]
    
    public init(hasModifiedSubstate_defaultValueToReturn: Bool = false,
                hasModifiedSubstate_valuesToReturn: [VersionedState : Bool] = [:],
                hasCompleteSubstate_defaultValueToReturn: Bool = false,
                hasCompleteSubstate_valuesToReturn: [VersionedState : Bool] = [:],
                hasSupportedSignature_defaultValueToReturn: Bool = false,
                hasSupportedSignature_valuesToReturn: [VersionSignature : Bool] = [:],
                file: StaticString = #file, line: UInt = #line) {
        
        self.hasModifiedSubstate_defaultValueToReturn = hasModifiedSubstate_defaultValueToReturn
        self.hasCompleteSubstate_defaultValueToReturn = hasCompleteSubstate_defaultValueToReturn
        self.hasSupportedSignature_defaultValueToReturn = hasSupportedSignature_defaultValueToReturn
        
        self.hasModifiedSubstate_valuesToReturn = hasModifiedSubstate_valuesToReturn
        self.hasCompleteSubstate_valuesToReturn = hasCompleteSubstate_valuesToReturn
        self.hasSupportedSignature_valuesToReturn = hasSupportedSignature_valuesToReturn
        
        super.init(file: file, line: line)
    }
    
    public func hasModifiedSubstate(oldState: VersionedState, newState: VersionedState) -> Bool {
        return self.hasModifiedSubstate_valuesToReturn[newState] ?? self.hasModifiedSubstate_defaultValueToReturn
    }
    
    public func hasCompleteSubstate(_ state: VersionedState) -> Bool {
        return self.hasCompleteSubstate_valuesToReturn[state] ?? self.hasCompleteSubstate_defaultValueToReturn
    }
    
    public func hasSupportedSignature(_ signature: VersionSignature) -> Bool {
        return self.hasSupportedSignature_valuesToReturn[signature] ?? self.hasSupportedSignature_defaultValueToReturn
    }
    
}
