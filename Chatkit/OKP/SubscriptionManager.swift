
protocol HasSubscriptionManager {
    var subscriptionManager: SubscriptionManager { get }
}

protocol SubscriptionManager {
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler)
}

class ConcreteSubscriptionManager: SubscriptionManager {
    
    typealias Dependencies = HasSubscriptionFactory
    
    private let dependencies: Dependencies
    
    private var subscriptions: [Subscription] = []
//    private var subscriptions: [Subscription: SubscriptionType] = [:]
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SubscriptionManager
    
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        let subscription = self.dependencies.subscriptionFactory.makeSubscription()
        subscription.subscribe(subscriptionType) { [weak self] result in
            guard let self = self else {
                return
            }
            
            // TODO: is it correct to not hold a reference on subscribe failure?
            if case .success = result {
                self.subscriptions.append(subscription)
            }
            completion(result)
        }
    }
}
