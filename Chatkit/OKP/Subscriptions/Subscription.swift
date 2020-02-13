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

class ConcreteSubscription: Subscription {
    
    enum State {
        case notSubscribed
        case subscribingStageOne(instance: Instance, completions: [SubscribeHandler])
        case subscribingStageTwo(instance: Instance, resumableSubscription: ResumableSubscription, completions: [SubscribeHandler])
        case subscribed(instance: Instance, resumableSubscription: ResumableSubscription)
    }
    
    typealias Dependencies = HasInstanceFactory
    
    let subscriptionType: SubscriptionType // Internal `get` aids testing
    private let dependencies: Dependencies
    weak var delegate: SubscriptionDelegate?
    
    private(set) var state: State = .notSubscribed // Internal `get` aids testing
    
    init(subscriptionType: SubscriptionType, dependencies: Dependencies, delegate: SubscriptionDelegate?) {
        self.subscriptionType = subscriptionType
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func subscribe(completion: @escaping SubscribeHandler) {
        
        switch (state) {
            
        case .notSubscribed:
            performSubscribe(completion: completion)
            
        case let .subscribingStageOne(instance, completions):
            // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingStageOne(instance: instance,
                                         completions: completions.appending(completion))
            
        case let .subscribingStageTwo(instance, resumableSubscription, completions):
            // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingStageTwo(instance: instance,
                                         resumableSubscription: resumableSubscription,
                                         completions: completions.appending(completion))
            
        case .subscribed:
            // Immediately invoke success, we're already subcribed
            completion(.success)
            
        }
    }
    
    func unsubscribe() {
        
        switch (state) {
            
        case .notSubscribed:
            // Nothing to do
            ()
            
        case let .subscribingStageOne(_, completions):
            
            state = .notSubscribed
            
            let error = Self.unsubscribeCalledWhileSubscribingError
            
            delegate?.subscription(self, didReceiveError: error)
            
            for completion in completions {
                completion(.failure(error))
            }
            
        case let .subscribingStageTwo(_, resumableSubscription, completions):
            
            resumableSubscription.onOpen = nil
            resumableSubscription.onError = nil
            resumableSubscription.end()
            
            state = .notSubscribed
            
            let error = Self.unsubscribeCalledWhileSubscribingError
            
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
        
        let instance = dependencies.instanceFactory.makeInstance(forType: .subscription(subscriptionType))
        
        let requestPath = makeRequestPath(for: subscriptionType)
        let requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: requestPath)
        
        let onEvent: Instance.OnEvent = { [weak self] _, _, any in
            guard let self = self else {
                return
            }
            
            switch self.state {
                
            case .notSubscribed, .subscribingStageOne:
                // We shouldn't ever be able to get here
                preconditionFailure("`performSubscribe` should never be called whilst in state `\(self.state)`")
                
            case let .subscribingStageTwo(instance, resumableSubscription, completions):
                
                // TODO: This should be removed once we've updated the PusherPlatform to return data rather than a jsonDict.
                guard let jsonDict = any as? [String: Any],
                    let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) else {
                        fatalError()
                }
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .subscribed(instance: instance, resumableSubscription: resumableSubscription)
                
                self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
                
                for completion in completions {
                    completion(.success)
                }
                
            case .subscribed(_, _):
                
                // TODO: This should be removed once we've updated the PusherPlatform to return data rather than a jsonDict.
                guard let jsonDict = any as? [String: Any],
                    let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) else {
                        // TODO: probably create a Json falvoured Error here and call `self.delegate?.subscription(self, didReceiveError: error)`
                        fatalError()
                }
                
                self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
                
            }
        }
        
        let onError: Instance.OnError = { [weak self] error in
            guard let self = self else {
                return
            }
            
            switch self.state {
                
            case .notSubscribed:
                // We shouldn't ever be able to get here
                preconditionFailure("`onError` should never be called whilst in state `\(self.state)`")
                
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
                
                // TODO is ordering correct?
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case .subscribed(_, _):
                
                self.delegate?.subscription(self, didReceiveError: error)
                
            }
        }
        
        let onEnd: Instance.OnEnd = { [weak self] statusCode, headers, info in
            guard let self = self else {
                return
            }
            
            switch self.state {
                
            case .notSubscribed:
                let error = Self.onEndReceivedWhileNotSubscribedError
                self.delegate?.subscription(self, didReceiveError: error)
                return
                
            case let .subscribingStageOne(_, completions):
                
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed

                let error = Self.onEndReceivedWhileSubscribingError
                
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
                
                let error = Self.onEndReceivedWhileSubscribingError
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case .subscribed(_, _):
                
                self.state = .notSubscribed
                
                let error = Self.onEndReceivedWhileSubscribedError
                
                self.delegate?.subscription(self, didReceiveError: error)
                
            }
            
        }
        
        // The ORDER of the code here is VITAL:
        
        state = .subscribingStageOne(instance: instance, completions: [completion])
        
        let resumableSubscription = instance.subscribeWithResume(using: requestOptions,
                                                                 onOpening: nil,
                                                                 onOpen: nil,
                                                                 onResuming: nil,
                                                                 onEvent: onEvent,
                                                                 onEnd: onEnd,
                                                                 onError: onError)
        
        state = .subscribingStageTwo(instance: instance,
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
    
    private static var unsubscribeCalledWhileSubscribingError: Error
        = "ERROR: `unsubscribe` called whilst still in the process of subscribing"
    
    private static var onEndReceivedWhileNotSubscribedError: Error
        = "ERROR: `onEnd` received unexpectedly whilst not subscribed"
    
    private static var onEndReceivedWhileSubscribingError: Error
        = "ERROR: `onEnd` received unexpectedly whilst still in the process of subscribing"
    
    private static var onEndReceivedWhileSubscribedError: Error
        = "ERROR: `onEnd` received unexpectedly whilst subscribed"
    
}
