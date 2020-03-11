
struct AuxiliaryState: State {
    
    // MARK: - Properties
    
    let subscriptions: [SubscriptionType : ConnectionState]
    
    static let empty: AuxiliaryState = AuxiliaryState(subscriptions: [:])
    
    // MARK: - Accessors
    
    let isComplete = true
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: AuxiliaryState) -> AuxiliaryState {
        let subscriptions = self.subscriptions.reduce(into: [SubscriptionType : ConnectionState]()) {
            if let supplementalSubscription = supplementalState.subscriptions[$1.key] {
                $0[$1.key] = $1.value.supplement(withState: supplementalSubscription)
            }
            else {
                $0[$1.key] = $1.value
            }
        }
        
        return AuxiliaryState(subscriptions: subscriptions)
    }
    
}
