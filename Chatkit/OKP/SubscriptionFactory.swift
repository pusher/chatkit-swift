
protocol HasSubscriptionFactory {
    var subscriptionFactory: SubscriptionFactory { get }
}

protocol SubscriptionFactory {
    func makeSubscription() -> Subscription
}

class ConcreteSubscriptionFactory: SubscriptionFactory {
    
    typealias Dependencies = HasInstanceFactory & HasSubscriptionResponder
    
    private let dependencies: Dependencies
    private let subscriptionResponder: SubscriptionResponder
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.subscriptionResponder = dependencies.subscriptionResponder
    }
    
    // MARK: SubscriptionFactory
    
    func makeSubscription() -> Subscription {
        return ConcreteSubscription(dependencies: dependencies,
                                    delegate: subscriptionResponder)
    }
}
