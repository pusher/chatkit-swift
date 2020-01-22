
protocol HasSubscriptionResponder {
    var subscriptionResponder: SubscriptionResponder { get }
}

protocol SubscriptionResponder: SubscriptionDelegate {
}

class ConcreteSubscriptionResponder: SubscriptionResponder {
    
    typealias Dependencies = HasStore
    
    let dependencies: Dependencies
    
    private let jsonDecoder = JSONDecoder.default
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SubscriptionDelegate
    
    func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data) {
        
        // TODO move parsing elsewhere?
        do {
            let subscriptionEvent = try self.jsonDecoder.decode(Wire.Event.Subscription.self, from: jsonData)
            let action = Action.subscriptionEvent(subscriptionEvent.data)
            self.dependencies.store.action(action)
        }
        catch {
            // ???
            print(error)
            fatalError()
        }
    }
    
    func subscription(_ subscription: Subscription, didReceiveError: Error) {
        // TODO
        fatalError()
    }
}