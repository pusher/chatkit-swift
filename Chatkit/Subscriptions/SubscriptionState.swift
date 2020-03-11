
enum SubscriptionState {
    
    case notSubscribed
    case subscribingStageOne(instanceWrapper: InstanceWrapper, completions: [SubscribeHandler])
    case subscribingStageTwo(instanceWrapper: InstanceWrapper, resumableSubscription: ResumableSubscription, completions: [SubscribeHandler])
    case subscribed(instanceWrapper: InstanceWrapper, resumableSubscription: ResumableSubscription)
    
}

extension SubscriptionState: Equatable {
    
    static func == (lhs: SubscriptionState, rhs: SubscriptionState) -> Bool {
        switch (lhs, rhs) {
        case (.notSubscribed,
              .notSubscribed),
             (.subscribingStageOne,
              .subscribingStageOne),
             (.subscribingStageTwo,
              .subscribingStageTwo),
             (.subscribed,
              .subscribed):
            return true
            
        default:
            return false
        }
    }
    
}
