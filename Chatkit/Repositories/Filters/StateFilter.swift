
protocol StateFilter {
    
    func hasModifiedSubstate(oldState: VersionedState, newState: VersionedState) -> Bool
    func hasCompleteSubstate(_ state: VersionedState) -> Bool
    func hasRelevantSignature(_ signature: VersionSignature) -> Bool
    
}
