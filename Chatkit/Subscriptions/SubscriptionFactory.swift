
protocol HasSubscriptionFactory {
    var subscriptionFactory: SubscriptionFactory { get }
}

protocol SubscriptionFactory {
    func makeSubscription(subscriptionType: SubscriptionType) -> Subscription
}

class ConcreteSubscriptionFactory: SubscriptionFactory {
    
    typealias Dependencies = HasInstanceWrapperFactory & HasSubscriptionActionDispatcher & HasStore
    
    private let dependencies: Dependencies
    private let subscriptionActionDispatcher: SubscriptionActionDispatcher
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.subscriptionActionDispatcher = dependencies.subscriptionActionDispatcher
    }
    
    // MARK: SubscriptionFactory
    
    func makeSubscription(subscriptionType: SubscriptionType) -> Subscription {
        return ConcreteSubscription(subscriptionType: subscriptionType,
                                    dependencies: dependencies,
                                    delegate: subscriptionActionDispatcher)
    }
}
