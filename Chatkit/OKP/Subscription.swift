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
    
    private enum State {
        case notSubscribed
        case subscribingA(instance: Instance, completions: [SubscribeHandler])
        case subscribingB(instance: Instance, resumableSubscription: ResumableSubscription, completions: [SubscribeHandler])
        case subscribed(instance: Instance, resumableSubscription: ResumableSubscription)
    }
    
    typealias Dependencies = HasInstanceFactory

    internal let subscriptionType: SubscriptionType
    private let dependencies: Dependencies
    weak var delegate: SubscriptionDelegate?
    
    private var state: State = .notSubscribed
    
    init(subscriptionType: SubscriptionType, dependencies: Dependencies, delegate: SubscriptionDelegate?) {
        self.subscriptionType = subscriptionType
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func subscribe(completion: @escaping SubscribeHandler) {
        
        switch (state) {
            
        case .notSubscribed:
            performSubscribe(completion: completion)
        
        case let .subscribingA(instance, completions):
        // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingA(instance: instance,
                                  completions: completions.appending(completion))
            
        case let .subscribingB(instance, resumableSubscription, completions):
            // Add the new completion handler to the `completions` of the .subscribing state
            state = .subscribingB(instance: instance,
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
        
        case let .subscribingA(_, completions):
            state = .notSubscribed
            let error = makeUnsubscribeCalledWhileSubscribingError()
            for completion in completions {
                completion(.failure(error))
            }
            
        case let .subscribingB(_, resumableSubscription, completions):
            
            resumableSubscription.onOpen = nil
            resumableSubscription.onError = nil
            resumableSubscription.end()
            
            state = .notSubscribed
            
            let error = makeUnsubscribeCalledWhileSubscribingError()
            for completion in completions {
                completion(.failure(error))
            }
            
        case let .subscribed(instance, resumableSubscription):
            
            resumableSubscription.onOpen = nil
            resumableSubscription.onError = nil
            resumableSubscription.end()
            
            print(instance)
            
            state = .notSubscribed
        }
    }
    
    // MARK: - Private
    
    private func performSubscribe(completion: @escaping SubscribeHandler) {

       let instance = self.dependencies.instanceFactory.makeInstance(forType: .subscription(subscriptionType))
   
       let requestPath = makeRequestPath(for: subscriptionType)
       let requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: requestPath)
   
        let onEvent: Instance.OnEvent = { [weak self] _, _, any in
            guard let self = self else {
                return
            }
            
            switch self.state {
            
            case .notSubscribed, .subscribingA:
                // TODO we shouldn't ever be able to get here in theory?
                preconditionFailure("This shouldn't be possible")
                
            case let .subscribingB(instance, resumableSubscription, completions):
                
                // TODO: Implement properly
                guard let jsonDict = any as? [String: Any],
                    let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) else {
                        // TODO: probably create a Json falvoured Error here and call `self.delegate?.subscription(self, didReceiveError: error)`
                        fatalError()
                }
                
                // TODO is ordering correct?
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .subscribed(instance: instance, resumableSubscription: resumableSubscription)
                
                self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
                
                for completion in completions {
                    completion(.success)
                }
                
            case .subscribed(_, _):
                
                // TODO: Implement properly
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
            
            //self.logger.log("Chat service subscription failed with error: \(error.localizedDescription)", logLevel: .warning)
            print(error)
            
            switch self.state {
                
            case .notSubscribed:
            // TODO we shouldn't ever be able to get here in theory?
                preconditionFailure("This shouldn't be possible")

            case let .subscribingA(_, completions):
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case let .subscribingB(_, resumableSubscription, completions):
                
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
            
            // TODO: I have no idea if this is correct at present
            // Extract an error, or make one
            let error: Error
            if let passedError: Error = info as? Error {
                error = passedError
            } else {
                let statusCodeString = statusCode != nil ? String(describing: statusCode) : "nil"
                let headersString = headers != nil ? String(describing: headers) : "nil"
                let infoString = info != nil ? String(describing: headers) : "nil"
                error = "Unknown reason for end. Status code=\(statusCodeString). Headers=\(headersString). Info=\(infoString)"
            }
            
            switch self.state {
                
            case .notSubscribed:
                // TODO ignore?
                return

                case let .subscribingA(_, completions):
                // TODO is ordering correct?
                // The ORDER of the code here is VITAL:
                //   We MUST set the state before we call the delegate/completions
                //   We MUST invoke the delegate method before the completions
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
                for completion in completions {
                    completion(.failure(error))
                }
                
            case let .subscribingB(_, resumableSubscription, completions):
                
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
                
                self.state = .notSubscribed
                
                self.delegate?.subscription(self, didReceiveError: error)
                
            }
            
        }
        

        // The ORDER of the code here is VITAL:
        
        state = .subscribingA(instance: instance, completions: [completion])
        
        let resumableSubscription = instance.subscribeWithResume(using: requestOptions,
                                                                 onOpening: nil,
                                                                 onOpen: nil,
                                                                 onResuming: nil,
                                                                 onEvent: onEvent,
                                                                 onEnd: onEnd,
                                                                 onError: onError)
        
        state = .subscribingB(instance: instance,
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
    
    private func makeUnsubscribeCalledWhileSubscribingError() -> Error {
        return "ERROR: `Unsubscribe` called whilst still in the process of subscribing"
    }
}
