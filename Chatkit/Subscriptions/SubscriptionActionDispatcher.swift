import Foundation

protocol HasSubscriptionActionDispatcher {
    var subscriptionActionDispatcher: SubscriptionActionDispatcher { get }
}

protocol SubscriptionActionDispatcher: SubscriptionDelegate {}

class ConcreteSubscriptionActionDispatcher: SubscriptionActionDispatcher {
    
    typealias Dependencies = HasStore
    
    private let dependencies: Dependencies
    
    private let jsonDecoder = JSONDecoder.default
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SubscriptionDelegate
    
    func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data) {
        
        do {
            let subscriptionEvent = try jsonDecoder.decode(Wire.Event.Subscription.self, from: jsonData)
            let action = Action.subscriptionEvent(subscriptionEvent.data)
            dependencies.store.action(action)
        } catch {
            // TODO: Subscription unhappy paths
            // It was decided to defer work on handling Subscription *un*happy paths in favour
            // of shipping the happy paths on the SDK
            print(error)
        }
    }
    
    func subscription(_ subscription: Subscription, didReceiveError error: Error) {
        // TODO: Subscription unhappy paths
        // It was decided to defer work on handling Subscription *un*happy paths in favour
        // of shipping the happy paths on the SDK
        // Ideally here we need to know if its a recoverable error or not
        print(error)
    }
}
