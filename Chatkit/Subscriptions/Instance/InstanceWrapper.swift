import Foundation
import class PusherPlatform.Instance
import class PusherPlatform.PPGeneralRequest
import class PusherPlatform.PPRequestOptions

// Its not possible to stub a PusherPlatform.Instance because it has no protocol so this
// protocol exists to resolve that problem.
protocol InstanceWrapper {
    
    typealias OnOpening = () -> Void
    typealias OnOpen = () -> Void
    typealias OnResuming = () -> Void
    typealias OnEvent = (_ eventId: String, _ headers: [String: String], _ data: Any) -> Void
    typealias OnEnd = (_ statusCode: Int?, _ headers: [String: String]?, _ info: Any?) -> Void
    typealias OnSuccess = (_ data: Data) -> Void
    typealias OnError = (_ error: Error) -> Void
    
    func request(using requestOptions: PPRequestOptions,
                 onSuccess: OnSuccess?,
                 onError: OnError?) -> PPGeneralRequest

    func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: OnOpening?,
                             onOpen: OnOpen?,
                             onResuming: OnResuming?,
                             onEvent: OnEvent?,
                             onEnd: OnEnd?,
                             onError: OnError?) -> ResumableSubscription
}

// This class simply proxies an internal PusherPlatform.Instance.
class ConcreteInstanceWrapper: InstanceWrapper {
    
    typealias Dependencies = HasInstanceLocator & HasSDKInfoProvider & HasTokenProvider
    
    let internalPPInstanceWrapper: PusherPlatform.Instance
    
    init(dependencies: Dependencies) {
        internalPPInstanceWrapper = PusherPlatform.Instance(
            instanceLocator: dependencies.instanceLocator,
            serviceName: dependencies.sdkInfoProvider.serviceName,
            serviceVersion: dependencies.sdkInfoProvider.serviceVersion,
            sdkInfo: dependencies.sdkInfoProvider.sdkInfo,
            tokenProvider: dependencies.tokenProvider
        )
    }
    
    func request(using requestOptions: PPRequestOptions,
                 onSuccess: OnSuccess?,
                 onError: OnError?) -> PPGeneralRequest {
        return internalPPInstanceWrapper.request(using: requestOptions, onSuccess: onSuccess, onError: onError)
    }
    
    func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: OnOpening?,
                             onOpen: OnOpen?,
                             onResuming: OnResuming?,
                             onEvent: OnEvent?,
                             onEnd: OnEnd?,
                             onError: OnError?) -> ResumableSubscription {
        
        return internalPPInstanceWrapper.subscribeWithResume(using: requestOptions,
                                                             onOpening: onOpening,
                                                             onOpen: onOpen,
                                                             onResuming: onResuming,
                                                             onEvent: jsonDataOnEvent(onEvent: onEvent),
                                                             onEnd: onEnd,
                                                             onError: onError)
    }
    
    // TODO: `PusherPlatform.Instance` to return (JSON) `Data`
    // This should be removed once we've updated the PusherPlatform to return jsonData rather than a jsonDict.
    private func jsonDataOnEvent(onEvent: OnEvent?) -> OnEvent? {
        
        guard let onEvent = onEvent else {
            return nil
        }
        return { (eventId: String, headers: [String: String], jsonDictAsAny: Any) in
            
            guard let jsonDict = jsonDictAsAny as? [String: Any],
                let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) else {
                    fatalError()
            }
            onEvent(eventId, headers, jsonData)
        }

    }
    
}