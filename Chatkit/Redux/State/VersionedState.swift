
struct VersionedState: State, Versionable {
    
    // MARK: - Properties
    
    let chatState: ChatState
    let version: Version
    let signature: VersionSignature
    
    static let initial: VersionedState = VersionedState(chatState: .empty, version: 0, signature: .unsigned)
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        return self.chatState.isComplete
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: VersionedState) -> VersionedState {
        let chatState = self.chatState.supplement(withState: supplementalState.chatState)
        
        return VersionedState(chatState: chatState,
                              version: self.version,
                              signature: self.signature)
    }
    
}

// MARK: - Equatable

extension VersionedState: Equatable {}

