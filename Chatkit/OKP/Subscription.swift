import Foundation
import class PusherPlatform.PPRequestOptions
import enum PusherPlatform.HTTPMethod

enum SubscriptionType {
    case user
    case room(roomIdentifier: String)
}

extension SubscriptionType: Hashable {}

typealias SubscribeHandler = (VoidResult) -> Void

protocol SubscriptionDelegate: AnyObject {
    func subscription(_ subscription: Subscription, didReceiveEventWithJsonData jsonData: Data)
    func subscription(_ subscription: Subscription, didReceiveError error: Error)
}

protocol Subscription {
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler)
}

class ConcreteSubscription: Subscription {
    
    typealias Dependencies = HasInstanceFactory

    private let dependencies: Dependencies
    weak var delegate: SubscriptionDelegate?
    
    init(dependencies: Dependencies, delegate: SubscriptionDelegate?) {
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func subscribe(_ subscriptionType: SubscriptionType, completion: @escaping SubscribeHandler) {
        
        let instance = self.dependencies.instanceFactory.makeInstance(forType: .subscription(subscriptionType))
    
        let requestPath = makeRequestPath(for: subscriptionType)
        let requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: requestPath)
    
        let onOpen = {
            // TODO: should we now nil `onOpen` to avoid the completion potentially being called again?
            completion(.success)
        }
    
        let onEvent: Instance.OnEvent = { [weak self] _, _, any in
            guard let self = self else {
                return
            }
            // TODO: Implement properly
            guard let jsonData = any as? Data else {
                // TODO: probably create a Json falvoured Error here and call `self.delegate?.subscription(self, didReceiveError: error)`
                fatalError()
            }
            self.delegate?.subscription(self, didReceiveEventWithJsonData: jsonData)
        }
        
        let onError: Instance.OnError = { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.delegate?.subscription(self, didReceiveError: error)
            
            fatalError()
            
            /*
             
            self.logger.log("Chat service subscription failed with error: \(error.localizedDescription)", logLevel: .warning)
            
            self.resumableSubscription.onOpen = nil
            self.resumableSubscription.onError = nil
            self.resumableSubscription.end()
            
            if let completionHandler = completionHandler {
                completionHandler(error)
            }
 
            */
        }
        
        let onEnd: Instance.OnEnd = { [weak self] statusCode, headers, info in
            
            // TODO: I have no idea if this is correct at present
            let error: Error
            if let passedError: Error = info as? Error {
                error = passedError
            } else {
                let statusCodeString = statusCode != nil ? String(describing: statusCode) : "nil"
                let headersString = headers != nil ? String(describing: headers) : "nil"
                let infoString = info != nil ? String(describing: headers) : "nil"
                error = "Unknown reason for end. Status code=\(statusCodeString). Headers=\(headersString). Info=\(infoString)"
            }
            completion(.failure(error))
        }
        
        _ = instance.subscribeWithResume(using: requestOptions,
                                         onOpening: nil,
                                         onOpen: onOpen,
                                         onResuming: nil,
                                         onEvent: onEvent,
                                         onEnd: onEnd,
                                         onError: onError)
    }
    
    // MARK: - Private
    
    private func makeRequestPath(for subscriptionType: SubscriptionType) -> String {
        switch subscriptionType {
        case .user:
            return "/users"
        case let .room(roomIdentifier):
            return "/room/\(roomIdentifier)"
        }
    }
    
}
