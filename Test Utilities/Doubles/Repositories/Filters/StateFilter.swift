import XCTest
@testable import PusherChatkit

public class StubStateFilter: DoubleBase, StateFilter {
    
    private let hasModifiedSubstate_defaultValueToReturn: Bool
    private let hasCompleteSubstate_defaultValueToReturn: Bool
    private let hasRelevantSignature_defaultValueToReturn: Bool
    
    private let hasModifiedSubstate_valuesToReturn: [VersionedState : Bool]
    private let hasCompleteSubstate_valuesToReturn: [VersionedState : Bool]
    private let hasRelevantSignature_valuesToReturn: [VersionSignature : Bool]
    
    public init(hasModifiedSubstate_defaultValueToReturn: Bool = false,
                hasModifiedSubstate_valuesToReturn: [VersionedState : Bool] = [:],
                hasCompleteSubstate_defaultValueToReturn: Bool = false,
                hasCompleteSubstate_valuesToReturn: [VersionedState : Bool] = [:],
                hasRelevantSignature_defaultValueToReturn: Bool = false,
                hasRelevantSignature_valuesToReturn: [VersionSignature : Bool] = [:],
                file: StaticString = #file, line: UInt = #line) {
        
        self.hasModifiedSubstate_defaultValueToReturn = hasModifiedSubstate_defaultValueToReturn
        self.hasCompleteSubstate_defaultValueToReturn = hasCompleteSubstate_defaultValueToReturn
        self.hasRelevantSignature_defaultValueToReturn = hasRelevantSignature_defaultValueToReturn
        
        self.hasModifiedSubstate_valuesToReturn = hasModifiedSubstate_valuesToReturn
        self.hasCompleteSubstate_valuesToReturn = hasCompleteSubstate_valuesToReturn
        self.hasRelevantSignature_valuesToReturn = hasRelevantSignature_valuesToReturn
        
        super.init(file: file, line: line)
    }
    
    public func hasModifiedSubstate(oldState: VersionedState, newState: VersionedState) -> Bool {
        return self.hasModifiedSubstate_valuesToReturn[newState] ?? self.hasModifiedSubstate_defaultValueToReturn
    }
    
    public func hasCompleteSubstate(_ state: VersionedState) -> Bool {
        return self.hasCompleteSubstate_valuesToReturn[state] ?? self.hasCompleteSubstate_defaultValueToReturn
    }
    
    public func hasRelevantSignature(_ signature: VersionSignature) -> Bool {
        return self.hasRelevantSignature_valuesToReturn[signature] ?? self.hasRelevantSignature_defaultValueToReturn
    }
    
}
