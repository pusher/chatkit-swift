
protocol HasSubscriptionManager {
    var subscriptionManager: SubscriptionManager { get }
}

protocol SubscriptionManager {
    func subscribe(toType subscriptionType: SubscriptionType, sender: AnyObject, completion: @escaping SubscribeHandler)
    func unsubscribe(fromType subscriptionType: SubscriptionType, sender: AnyObject)
    func unsubscribeFromAll()
}

class ConcreteSubscriptionManager: SubscriptionManager {
    
    typealias Dependencies = HasSubscriptionFactory
    typealias SubscriptionDetails = (subscription: Subscription, subscribers: NSHashTable<AnyObject>)
    
    private let dependencies: Dependencies
    private var subscriptionDetailsByType: [SubscriptionType: SubscriptionDetails] = [:]
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SubscriptionManager
    
    func subscribe(toType subscriptionType: SubscriptionType, sender: AnyObject, completion: @escaping SubscribeHandler) {
        
        let subscriptionDetails: SubscriptionDetails
        
        // Check if we are already have SubscriptionDetails for the specified SubscriptionType and if so use that
        if let subscriptionDetailsTmp = subscriptionDetailsByType[subscriptionType] {
            subscriptionDetails = subscriptionDetailsTmp
        } else {
            let subscription = dependencies.subscriptionFactory.makeSubscription(subscriptionType: subscriptionType)
            let subscribers = NSHashTable<AnyObject>.weakObjects()
            subscriptionDetails = (subscription: subscription, subscribers: subscribers)
            subscriptionDetailsByType[subscriptionType] = subscriptionDetails
        }

        // Hold a *weak* reference to the sender as a "subscriber"
        subscriptionDetails.subscribers.add(sender)
        
        // TODO: Subscription unhappy paths
        // It was decided to defer work on handling Subscription *un*happy paths in favour
        // of shipping the happy paths on the SDK
        // Do we need to remove the subscription from subscriptionsByType if the subscribe call fails?
        // At the moment I am thinking no because if someone calls subscribe again it should cause the dead
        // subscription to come back to life and reattempt connection
        
        subscriptionDetails.subscription.subscribe(completion: completion)
    }
    
    func unsubscribe(fromType subscriptionType: SubscriptionType, sender: AnyObject) {
        
        guard let subscriptionDetails = subscriptionDetailsByType[subscriptionType] else {
            return
        }
        
        subscriptionDetails.subscribers.remove(sender)
        
        // Only actually call `subscribe` on the subscription if there are no more `subscribers`
        if subscriptionDetails.subscribers.count <= 0 {
            subscriptionDetails.subscription.unsubscribe()
            subscriptionDetailsByType[subscriptionType] = nil
        }
    }
    
    func unsubscribeFromAll() {
        for (subscriptionType, subscriptionDetails) in subscriptionDetailsByType {
            // TODO: Subscription unhappy paths
            // It was decided to defer work on handling Subscription *un*happy paths in favour
            // of shipping the happy paths on the SDK
            // We need to work out what happens if unsubscribe fails, should we remove it from subscriptionsByType or not
            subscriptionDetails.subscription.unsubscribe()
            subscriptionDetailsByType.removeValue(forKey: subscriptionType)
        }
    }
    
}
