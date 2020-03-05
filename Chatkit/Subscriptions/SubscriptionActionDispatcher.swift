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
            
            let action: Action
            
            switch subscriptionEvent.data {

            case let .initialState(event):
                action = InitialStateAction(event: event)
            case let .addedToRoom(event):
                action = AddedToRoomAction(event: event)
            case let .removedFromRoom(event):
                action = RemovedFromRoomAction(event: event)
            case let .roomUpdated(event):
                action = RoomUpdatedAction(event: event)
            case let .roomDeleted(event):
                action = RoomDeletedAction(event: event)
            case let .readStateUpdated(event):
                action = ReadStateUpdatedAction(event: event)
            
            // TODO: not yet implemented
            case .userJoinedRoom, .userLeftRoom, .newMessage, .messageDeleted, .isTyping, .presenceState:
                preconditionFailure("Not yet implemented")
            
            }
            
            dependencies.store.dispatch(action: action)
                
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
