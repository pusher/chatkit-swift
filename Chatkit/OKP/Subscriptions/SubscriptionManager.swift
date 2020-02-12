
protocol HasSubscriptionManager {
    var subscriptionManager: SubscriptionManager { get }
}

protocol SubscriptionManager {
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler)
    func unsubscribe(_ subscriptionType: SubscriptionType)
    func unsubscribeFromAll()
}

class ConcreteSubscriptionManager: SubscriptionManager {
    
    typealias Dependencies = HasSubscriptionFactory
    
    private let dependencies: Dependencies
    
//    private var subscriptions: [Subscription] = []
    private var subscriptionsByType: [SubscriptionType: Subscription] = [:]
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SubscriptionManager
    
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        
        // Check if we are already have a subscription for the specified SubscriptionType and if so use that
        let subscription = subscriptionsByType[subscriptionType] ?? self.dependencies.subscriptionFactory.makeSubscription(subscriptionType: subscriptionType)

        // Immediately hold a reference to the subscription so we don't attempt to factory it again
        self.subscriptionsByType[subscriptionType] = subscription
        
        // TODO do we need to remove the subscription from subscriptionsByType if the subscribe call fails?
        // At the moment I am thinking no because if someone calls subscribe again it should cause the dead
        // subscription to come back to life and reattempt connection
        
        subscription.subscribe(completion: completion)
    }
    
    func unsubscribe(_ subscriptionType: SubscriptionType) {
        
    }
    
    func unsubscribeFromAll() {
        for (subscriptionType, subscription) in subscriptionsByType {
            // TODO work out what happens if unsubscribe fails, should we remove from subscriptionsByType or not
            subscription.unsubscribe()
            subscriptionsByType.removeValue(forKey: subscriptionType)
        }
    }
}
