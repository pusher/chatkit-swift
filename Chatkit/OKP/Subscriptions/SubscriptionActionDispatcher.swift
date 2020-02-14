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
            // TODO: work needs to be done on handling errors in future
            print(error)
        }
    }
    
    func subscription(_ subscription: Subscription, didReceiveError error: Error) {
        // TODO: work needs to be done on handling errors in future
        // Ideally we need to know if its a recoverable error or not
        print(error)
    }
}
