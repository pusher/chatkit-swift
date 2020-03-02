import Foundation
import class PusherPlatform.PPRequestOptions
import enum PusherPlatform.HTTPMethod

typealias SubscribeHandler = (VoidResult) -> Void

protocol SubscriptionDelegate: AnyObject {
    func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data)
    func subscription(_ subscription: Subscription, didReceiveError error: Error)
}

protocol Subscription {
    func subscribe(completion: @escaping SubscribeHandler)
    func unsubscribe()
}

enum SubscriptionError: String, LocalizedError {
    
    case unsubscribeCalledWhileSubscribingError = "ERROR: `unsubscribe` called whilst still in the process of subscribing"
    case onEndReceivedWhileNotSubscribedError = "ERROR: `onEnd` received unexpectedly whilst not subscribed"
    case onEndReceivedWhileSubscribingError = "ERROR: `onEnd` received unexpectedly whilst still in the process of subscribing"
    case onEndReceivedWhileSubscribedError  = "ERROR: `onEnd` received unexpectedly whilst subscribed"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

class ConcreteSubscription: Subscription {
    
    enum State {
        case notSubscribed
        case subscribingStageOne(instanceWrapper: InstanceWrapper, completions: [SubscribeHandler])
        case subscribingStageTwo(instanceWrapper: InstanceWrapper, resumableSubscription: ResumableSubscription, completions: [SubscribeHandler])
        case subscribed(instanceWrapper: InstanceWrapper, resumableSubscription: ResumableSubscription)
    }
    
    typealias Dependencies = HasInstanceWrapperFactory
    
    let subscriptionType: SubscriptionType // Internal `get` aids testing
    private let dependencies: Dependencies
    weak var delegate: SubscriptionDelegate?
    
    private(set) var state: State = .notSubscribed // Internal `get` aids testing
    
    init(subscriptionType: SubscriptionType, dependencies: Dependencies, delegate: SubscriptionDelegate) {
        self.subscriptionType = subscriptionType
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func subscribe(completion: @escaping SubscribeHandler) {
        
        switch state {
            
        case .notSubscribed:
            performSubscribe(completion: completion)
            
        case let .subscribingStageOne(instanceWrapper, completions):
            // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingStageOne(instanceWrapper: instanceWrapper,
                                         completions: completions.appending(completion))
            
        case let .subscribingStageTwo(instanceWrapper, resumableSubscription, completions):
            // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingStageTwo(instanceWrapper: instanceWrapper,
                                         resumableSubscription: resumableSubscription,
                                         completions: completions.appending(completion))
            
        case .subscribed:
            // Immediately invoke success, we're already subcribed
            completion(.success)
            
        }
    }
    
    func unsubscribe() {
        
        switch state {
            
        case .notSubscribed:
            // Nothing to do
            break
            
        case let .subscribingStageOne(_, completions):
            
            state = .notSubscribed
            
            let error: SubscriptionError = .unsubscribeCalledWhileSubscribingError
            
            delegate?.subscription(self, didReceiveError: error)
            
            for completion in completions {
                completion(.failure(error))
            }
            
        case let .subscribingStageTwo(_, resumableSubscription, completions):
            
            resumableSubscription.onOpen = nil
            resumableSubscription.onError = nil
            resumableSubscription.end()
            
            state = .notSubscribed
            
            let error: SubscriptionError = .unsubscribeCalledWhileSubscribingError
            
            delegate?.subscription(self, didReceiveError: error)
            
            for completion in completions {
                completion(.failure(error))
            }
            
        case let .subscribed(_, resumableSubscription):
            
            resumableSubscription.onOpen = nil
            resumableSubscription.onError = nil
            resumableSubscription.end()
            
            state = .notSubscribed
        }
    }
    
    // MARK: - Private
    
    private func performSubscribe(completion: @escaping SubscribeHandler) {
        
        let instanceWrapper = dependencies.instanceWrapperFactory.makeInstanceWrapper(forType: .subscription(subscriptionType))
        
        let requestPath = makeRequestPath(for: subscriptionType)
        let requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: requestPath)
        
        let onEvent: InstanceWrapper.OnEvent = { [weak self] _, _, jsonDataAsAny in
            guard let self = self else {
                return
            }
            
            // TODO: `PusherPlatform.Instance` to return (JSON) `Data`
            // This should be removed once we've updated the PusherPlatform to return jsonData rather than a jsonDict.
            guard let jsonData = jsonDataAsAny as? Data else {
                assertionFailure("`onEvent` called with non-`Data` typed data")
                return
            }
            
            switch self.state {
                
            case .notSubscribed, .subscribingStageOne:
                // We shouldn't ever be able to get here
                assertionFailure("UNEXPECTED: `onEvent` should never be called whilst in state `\(self.state)`")
                
            case let .subscribingStageTwo(instanceWrapper, resumableSubscription, completions):
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .subscribed(instanceWrapper: instanceWrapper, resumableSubscription: resumableSubscription)
                
                self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
                
                for completion in completions {
                    completion(.success)
                }
                
            case .subscribed:
                
                self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
                
            }
        }
        
        let onError: InstanceWrapper.OnError = { [weak self] error in
            guard let self = self else {
                return
            }
            
            switch self.state {
                
            case .notSubscribed:
                // We shouldn't ever be able to get here
                assertionFailure("`onError` should never be called whilst in state `\(self.state)`")
                
            case let .subscribingStageOne(_, completions):
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case let .subscribingStageTwo(_, resumableSubscription, completions):
                
                resumableSubscription.onOpen = nil
                resumableSubscription.onError = nil
                resumableSubscription.end()
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case .subscribed:
                
                self.delegate?.subscription(self, didReceiveError: error)
                
            }
        }
        
        let onEnd: InstanceWrapper.OnEnd = { [weak self] _, _, _ in
            guard let self = self else {
                return
            }
            
            switch self.state {
                
            case .notSubscribed:
                let error: SubscriptionError = .onEndReceivedWhileNotSubscribedError
                self.delegate?.subscription(self, didReceiveError: error)
                return
                
            case let .subscribingStageOne(_, completions):
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed

                let error: SubscriptionError = .onEndReceivedWhileSubscribingError
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case let .subscribingStageTwo(_, resumableSubscription, completions):
                
                resumableSubscription.onOpen = nil
                resumableSubscription.onError = nil
                resumableSubscription.end()
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed
                
                let error: SubscriptionError = .onEndReceivedWhileSubscribingError
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case .subscribed:
                
                self.state = .notSubscribed
                
                let error: SubscriptionError = .onEndReceivedWhileSubscribedError
                
                self.delegate?.subscription(self, didReceiveError: error)
                
            }
            
        }
        
        // The ORDER of the code here is VITAL:
        
        state = .subscribingStageOne(instanceWrapper: instanceWrapper, completions: [completion])
        
        let resumableSubscription = instanceWrapper.subscribeWithResume(using: requestOptions,
                                                                        onOpening: nil,
                                                                        onOpen: nil,
                                                                        onResuming: nil,
                                                                        onEvent: onEvent,
                                                                        onEnd: onEnd,
                                                                        onError: onError)
        
        state = .subscribingStageTwo(instanceWrapper: instanceWrapper,
                                     resumableSubscription: resumableSubscription,
                                     completions: [completion])
        
    }
    
    private func makeRequestPath(for subscriptionType: SubscriptionType) -> String {
        switch subscriptionType {
        case .user:
            return "/users"
        case let .room(roomIdentifier):
            return "/room/\(roomIdentifier)"
        }
    }
    
}
