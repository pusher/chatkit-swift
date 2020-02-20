
protocol StateFilter {
    
    func hasModifiedSubstate(oldState: VersionedState, newState: VersionedState) -> Bool
    func hasCompleteSubstate(_ state: VersionedState) -> Bool
    func hasSupportedSignature(_ signature: VersionSignature) -> Bool
    
}

// MARK: - Dependencies

protocol HasStateFilter {
    
    var stateFilter: StateFilter { get }
    
}
